module SessionsHelper
  # Handle all of the Sign in functions
# def sign_in(user, remember_me)
#   remember_token = User.new_remember_token
    #  Use of cookies to save a session for longer than browser duration
#   if remember_me
#     cookies.permanent[:remember_token] = remember_token
#   else
#     cookies[:remember_token] = remember_token
#   end
#   user.update_attribute(:remember_token, User.encrypt(remember_token))
#   self.current_user = user
# end
  # Logs in the current user
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the current logged-in user (if any).
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
    #  Use of cookies to save a session for longer than browser duration
#   cookies.delete(:remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in_user
    unless logged_in?
      store_location
      redirect_to login_url, notice: "Please sign in."
    end
  end

  def confirmed_user
     redirect_to root_url unless current_user.confirmed?
  end

  def admin_user
     redirect_to root_url unless current_user.admin?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

end
