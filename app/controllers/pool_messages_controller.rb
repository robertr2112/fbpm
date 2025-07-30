class PoolMessagesController < ApplicationController
  before_action :logged_in_user
  before_action :activated_user

  def new
    @pool = Pool.find_by_id(params[:pool_id])
  end

  def create
    @pool = Pool.find_by_id(params[:pool_id])
    if @pool.nil?
      redirect_to @pool, notice: "Email not sent. Could not find pool!"
    end

    # Get a list of users email addresses and phone numbers based on contact preferences
    users = Array.new
    @pool.users.each do |user|
      if params[:allMembers] == "true"
        entries = Entry.where(pool_id: @pool.id, user_id: user.id)
      else
        entries = Entry.where(pool_id: @pool.id, user_id: user.id, survivorStatusIn: true)
      end
      if entries.any?
        users << user
      end
    end
    sorted_users = getSortedContacts(users)
    email_addrs = sorted_users[:email_addrs]
    phone_nmbrs = sorted_users[:phone_nmbrs]

    # Send message via email to all users who have email or both as a contact preference
    if PoolMailer.send_pool_message(@pool, params[:subject],
                                    params[:msg], email_addrs).deliver_now
      message_sent = true
    else
      message_sent = false
    end

    # Send message via SMS to all users who have text or both as a contact preference
    msg = "Fbpm.club msg: " + @pool.name + "\n" + params[:msg]
    message_sent = send_SMS_messages(phone_nmbrs, msg)
    # If email and text messages were sent ok
    if message_sent
      redirect_to @pool, notice: "Message sent!"
    else
      redirect_to @pool,
              notice: "Message not sent. There was a problem with sending the message!"
    end
  end

  # Build an invite message
  def invite
    @pool = Pool.find_by_id(params[:id])
    if @pool.nil?
      redirect_to @pool, notice: "Email not sent. Could not find pool!"
    end
    @email_addr_errors = Array.new
    @phone_errors = Array.new
    # Build list of pools owned by current user to populate form for selection
    @pool_list = Array.new
    current_user.pools.each do |pool|
      if pool.isOwner?(current_user)
        @pool_list << pool
      end
    end
  end

  # Send invite message after form
  def send_invite
    @pool = Pool.find_by_id(params[:id])
    if @pool.nil?
      redirect_to @pool, notice: "Email not sent. Could not find pool!"
    end

    @phone_errors = Array.new
    @email_addr_errors = Array.new
    email_addrs = Array.new
    phone_nmbrs = Array.new

    # Build list of pools owned by current user to populate form for selection
    # !!! Not sure if this is necessary or not
    @pool_list = Array.new
    current_user.pools.each do |pool|
      # Only add pool to list if the current user is the owner of the pool
      if pool.isOwner?(current_user)
        @pool_list << pool
      end
    end

    # Get list of email addresses and phone numbers from selected pool
    if !params[:PoolList].blank?
      poolList = Pool.find_by_id(params[:PoolList])
    end
    if poolList
      sorted_users = getSortedContacts(poolList.users)
      email_addrs = sorted_users[:email_addrs]
      phone_nmbrs = sorted_users[:phone_nmbrs]
    end

    # Parse through list of comma seperated email addresses
    emailList = params[:emailListAddrs].split(",")
    emailList.each do |emailAddr|
      emailAddr = emailAddr.strip
      if !validate_email(emailAddr)
        @email_addr_errors << "There is an error with address: #{emailAddr}"
      else
        email_addrs << emailAddr
      end
    end

    # Parse through list of comma seperated phone numbers
    invite_message = Pool::POOL_INVITE_MSG + " <" + pool_url(@pool) + ">\n "
    invite_message += params[:msg]
    phoneList = params[:phoneListNmbrs].split(",")
    phoneList.each do |phoneNmbr|
      phoneNmbr = phoneNmbr.strip
      if !Phonelib.valid?(phoneNmbr)
        @phone_errors << "There is an error with phone number: #{phoneNmbr}"
      else
        phone_nmbrs << phoneNmbr
      end
    end

    # Check for errors
    if email_addrs.empty?
      @email_addr_errors << "No email addresses specified!"
    end
    if phone_nmbrs.empty?
      @phone_errors << "No phone numbers specified!"
    end

    if @email_addr_errors.empty? || @phone_errors.empty?

      # Send message via email to all users who have email or both as a contact preference
      if !email_addrs.empty?
        if PoolMailer.send_pool_invite(@pool, params[:subject],
                                       params[:msg], email_addrs).deliver_now
          message_sent = true
        else
          message_sent = false
        end
      end

      # Send message via SMS to all users who have text or both as a contact preference
      if !phone_nmbrs.empty?
        message_sent = send_SMS_messages(phone_nmbrs, invite_message)
      end

      if message_sent
          redirect_to @pool, notice: "Message sent!"
      else
          redirect_to @pool,
               notice: "Message not sent. There was a problem with sending the message!"
      end
    else
      flash[:danger] = "There were errors with the form!" + " : " + @email_addr_errors[0] +
                       " " + @phone_errors[0]
      render "invite"
    end
  end

  private

    def validate_email(emailAddr)
      EmailValidator.valid?(emailAddr)
    end

    # This module returns a sorted list of phone numbers and
    # email address based on the users contact preferences
    def getSortedContacts(users)
      sorted_users = {}
      sorted_users[:email_addrs] = Array.new
      sorted_users[:phone_nmbrs] = Array.new

      users.each do |user|
        if (user.contact == User::CONTACT_PREF[:Both]) ||
            (user.contact == User::CONTACT_PREF[:Email])

          sorted_users[:email_addrs] << user.email
        end
        if (user.contact == User::CONTACT_PREF[:Both]) ||
              (user.contact == User::CONTACT_PREF[:Text])

          sorted_users[:phone_nmbrs] << user.phone
        end
      end

      sorted_users
    end

    # Send messages to list of phone numbers
    def send_SMS_messages(phone_nmbrs, msg)
      message_sent = false
      phone_nmbrs.each do |phoneNmbr|
        # Send the message to all phone numbers
        if Rails.env.development?
          logger.info phoneNmbr
          logger.info msg
          message_sent = true
        else
          message_sent = TwilioClient.new.send_text(phoneNmbr, msg)
        end
      end
      message_sent
    end
end
