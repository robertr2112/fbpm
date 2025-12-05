require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SeasonsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  context "When user logs in" do
    let(:user) { FactoryBot.create(:user) }

    it "current_user returns right user after sign in" do
      sign_in_as(user)
      expect(user).to eq current_user
    end

    it "current_user returns nil after sign out of user" do
      sign_out
      expect(current_user).to be nil
    end
  end
end
