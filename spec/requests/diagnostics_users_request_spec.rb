require 'rails_helper'

RSpec.describe "Diagnostics Users (requests)", type: :request do
  describe 'POST /users/diag_chg/:id' do
    let!(:admin) { create(:admin, password: 'password', password_confirmation: 'password') }
    let!(:user) { create(:user) }

    def sign_in_as(user)
      post session_path, params: { email: user.email, password: 'password' }
      follow_redirect! if response.redirect?
    end

    it 'returns turbo-stream replacing user frame and flash for admin' do
      sign_in_as(admin)

      post user_diag_chg_path(user), params: { commands: ['user_pw'], user: { password: 'newsecure', password_confirmation: 'newsecure' } }, headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to match(/turbo-stream/)
      body = response.body
      # Expect turbo-stream replace for user's dom id
      expect(body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(user)}"))
      # Expect turbo-stream replace for flash target
      expect(body).to include('target="flash"')

      # Ensure password actually changed
      expect(User.find(user.id).authenticate('newsecure')).to be_truthy
    end

    it 'returns 403 turbo-stream flash replace for non-admin' do
      non_admin = create(:user, password: 'password', password_confirmation: 'password')
      sign_in_as(non_admin)

      post user_diag_chg_path(user), params: { commands: ['user_pw'], user: { password: 'anotherpw', password_confirmation: 'anotherpw' } }, headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

      expect(response.status).to eq(403)
      expect(response.media_type).to match(/turbo-stream/)
      expect(response.body).to include('target="flash"')
    end
  end
end
