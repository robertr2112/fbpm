class UserMailer < ActionMailer::Base
  # This won't work until we have an official domain name
  #default from: "info@footballpoolmania.com"
  default from: "fbpoolmania@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    attachments.inline['fbpm_logo.png'] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    mail to: user.email, subject: "Password Reset"
  end

  def account_activation(user)
    @user = user
    attachments.inline['fbpm_logo.png'] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    mail to: user.email, subject: "Account activation"
  end
end
