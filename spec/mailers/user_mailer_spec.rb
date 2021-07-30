require 'rails_helper'

RSpec.describe "AccountActivations", type: :mailer do

  describe "account_activation" do
    before do
      @user = User.new(name: "Example User", user_name: "user1", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
      @user.activation_token = User.new_token
      @mail = UserMailer.account_activation(@user)
    end

    it "Should have the right subject" do
      assert_equal "Account activation", @mail.subject
    end

    it "Should have the correct mail_to address" do
      assert_equal [@user.email], @mail.to
    end

    it "should have the correct mail_from address" do
      assert_equal ["info@footballpoolmania.com"], @mail.from
    end
    
    it "should have the correct email contents" do
      assert_match @user.name,               @mail.body.encoded
      assert_match @user.activation_token,   @mail.body.encoded
      assert_match CGI.escape(@user.email),  @mail.body.encoded
    end
  end

end
