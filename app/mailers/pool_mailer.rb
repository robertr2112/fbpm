class PoolMailer < ActionMailer::Base

  def send_pool_message(pool, subject, msg, email_list)
    # Setup variables used in mailer view
    @pool = pool
    @msg = msg

    # Call mailer
    subject_text = pool.name + "- " + subject
    attachments.inline['fbpm_logo.png'] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    if mail to: email_list, from: "fbpoolmania@gmail.com", subject: subject_text
      return false
    else
      return true
    end
  end

  def send_pool_invite(pool, subject, msg, email_list)
    # Setup variables used in mailer view
    @pool = pool
    @msg = msg

    # Call mailer
    subject_text = pool.name + "- " + subject
    attachments.inline['fbpm_logo.png'] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    if mail to: email_list, from: "fbpoolmania@gmail.com", subject: subject_text
      return false
    else
      return true
    end
  end
end
