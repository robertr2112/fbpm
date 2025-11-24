class PasswordsMailer < ApplicationMailer
  # Set default mail from field
  default from: "fbpm.club"

  def reset(user)
    @user = user
    attachments.inline["fbpm_logo.png"] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    mail subject: "Reset your password", to: user.email
  end
end
