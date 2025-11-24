module SessionsHelper
  # Returns the current logged-in user (if any).
  def current_user
    @current_user = Current.user
  end

  def current_user?(user)
    user == Current.user
  end

  def activated_user
    if current_user
      if !current_user.activated?
        flash[:notice] = "You must activate account before using the site!"
        redirect_to current_user
      end
    end
  end

  def admin_user
     redirect_to root_url unless current_user.admin?
  end
end
