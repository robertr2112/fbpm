class EmailAddressVerificationsController < ApplicationController
  # Handle activating the account
  def show
    user = User.find_by_email_address_verification_token(params[:token])
    if user == current_user && !user.activated?
      user.activate
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

  def resend
    if current_user.activated?
      flash[:notice] = "User account has already been activated!"
    else
      UserMailer.verify_email_address(current_user).deliver_later
      flash[:success] = "Activate account message has been resent!"
    end
    redirect_to root_url
  end
end
