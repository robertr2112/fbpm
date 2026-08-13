require 'rails_helper'

RSpec.describe Diagnostics::UsersDiagnostics do
  describe '#handle_change' do
    let(:service) { described_class.new }
    let(:user) { create(:user) }

    it 'returns error when user not found' do
      result = service.handle_change({ id: 0 })
      expect(result[:status]).to eq(:error)
      expect(result[:error]).to eq('user_not_found')
    end

    it 'sets a new password when user_pw command is provided and password valid' do
      params = { id: user.id, commands: ['user_pw'], user: { password: 'newsecure', password_confirmation: 'newsecure' } }
      result = service.handle_change(params)

      expect(result[:user]).to be_present

      pw_res = result[:results].find { |r| r[:command] == 'user_pw' }
      expect(pw_res).to be_present
      expect(pw_res[:result][:status]).to eq(:ok)

      # Reload user and verify password was changed (authenticate returns user when ok)
      expect(User.find(user.id).authenticate('newsecure')).to be_truthy
    end

    it 'returns validation errors when password is too short' do
      params = { id: user.id, commands: ['user_pw'], user: { password: 'abc', password_confirmation: 'abc' } }
      result = service.handle_change(params)

      pw_res = result[:results].find { |r| r[:command] == 'user_pw' }
      expect(pw_res[:result][:status]).to eq(:error)
      expect(pw_res[:result][:errors].any?).to be true
      expect(pw_res[:result][:errors].join).to match(/too short|minimum/i)
    end

    it 'returns a confirmation mismatch error when password and confirmation differ' do
      params = { id: user.id, commands: ['user_pw'], user: { password: 'securepw', password_confirmation: 'nomatch' } }
      result = service.handle_change(params)

      pw_res = result[:results].find { |r| r[:command] == 'user_pw' }
      expect(pw_res[:result][:status]).to eq(:error)
      # The exact message can vary, so check for "match" or "confirmation" keywords
      joined = pw_res[:result][:errors].join(' ')
      expect(joined.downcase).to match(/match|confirmation/)
    end

    it 'accepts comma-separated commands string' do
      params = { id: user.id, commands: 'user_pw,unknown_cmd', user: { password: 'anotherpw', password_confirmation: 'anotherpw' } }
      result = service.handle_change(params)
      expect(result[:results].map { |r| r[:command] }).to include('user_pw', 'unknown_cmd')
      pw_res = result[:results].find { |r| r[:command] == 'user_pw' }
      expect(pw_res[:result][:status]).to eq(:ok)
    end
  end
end
