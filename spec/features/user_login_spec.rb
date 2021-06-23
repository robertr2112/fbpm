require 'rails_helper'

RSpec.feature "Static pages", type: :feature do

  subject { page }
  
  feature "When visiting the login page" do
    scenario "with invalid login information" do
      visit(login_path)
      should have_title('Log in')
      find('#signin_email').set(user.email)
      find('#signin_password').set(user.password)
      find('#signin_button').click
      should have_title('Log in')
      expect(flash.empty?).not_to be true
      visit(root_path)
      expect(flash.empty?).to be true
    end
  end
end
