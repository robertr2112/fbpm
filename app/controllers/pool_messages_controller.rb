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

    if params[:allMembers] == "true"
      allMembers = true
    else
      allMembers = false
    end

    # Send message via SMS to all users who have SMS as a contact preference


    # Send message via email to all users who have email as a contact preference
    if PoolMailer.send_pool_message(@pool, params[:subject], params[:msg], allMembers).deliver_now
      redirect_to @pool, notice: "Email sent!"
    else
      redirect_to @pool, notice: "Email not sent. There was a problem with the mailer!"
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

    # Build list of pools owned by current user to populate form for selection
    @pool_list = Array.new
    current_user.pools.each do |pool|
      # Only add pool to list if the current user is the owner of the pool
      if pool.isOwner?(current_user)
        @pool_list << pool
      end
    end

    # Build list of phone numbers and email addresses
    @phone_errors = Array.new
    phone_addrs = Array.new
    @email_addr_errors = Array.new
    email_addrs = Array.new
    if !params[:PoolList].blank?
      poolList = Pool.find_by_id(params[:emailPoolList])
    end
    if poolList
      poolList.users.each do |user|
        # Only add email to list if that user wants to be sent email
        if user.contact == User::CONTACT_PREF[:Both] || User::CONTACT_PREF[:Email]
          email_addrs << user.email
        end
        if user.contact == User::CONTACT_PREF[:Both] || User::CONTACT_PREF[:Text]
          phone_addrs << user.phone
        end
      end
    end
    # Parse through list of comma seperated emails addresses
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
    phoneList = params[:phoneListNmbrs].split(",")
    phoneList.each do |phoneNmbr|
      phoneNmbr = emailAddr.strip
      if !Phonelib.valid?(phoneNmbr)
        @phone_errors << "There is an error with phone number: #{phoneNmbr}"
      else
        phone_nmbrs << phoneNmbr
      end
    end

    if email_addrs.empty?
      @email_addr_errors << "You need to add email addresses to send this message!"
    end
    if phone_nmbrs.empty?
      @phone_errors << "You need to add phone numbers to send this message!"
    end
    if @email_addr_errors.empty? && @phone_errors.empty?
      # Send message to users who have selected email as a contact preference
      if !email_addrs.empty?
        if PoolMailer.send_pool_invite(@pool, params[:subject], params[:msg], email_addrs).deliver_now
          message_sent = true
        else
          message_sent = false
        end
      end
      if !phone_nmbrs.empty?
        phoneNmbrs.each do phoneNmbr
          # Build the invite text message
          
          # Send the message to all phone numbers
          TwilioClient.new.send_text(phoneNmbr, params[:msg])
        end
      end
      if message_sent
          redirect_to @pool, notice: "Message sent!"
      else
          redirect_to @pool, notice: "Message not sent. There was a problem with sending the message!"
      end
    else
      flash[:danger] = "There were errors with the form!"
      render 'invite'
      return
    end
  end

  private

    def validate_email(emailAddr)
      EmailValidator.valid?(emailAddr)
    end
end
