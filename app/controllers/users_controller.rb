class UsersController < ApplicationController
  before_action :correct_user, only: [ :edit, :update ]
  before_action :admin_user, only: [:destroy, :user_diagnostics, :user_diag_chg, :user_row]

  def index
    if current_user.admin?
      @pagy, @users = pagy(User.all, limit: 10)
    else
      @pagy, @users = pagy(User.where(activated: true), limit: 10)
    end
  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def edit
  end

  def update
     respond_to do |format|
      if @user.update(user_params)
        flash[:success] = "Profile updated"
        format.html { redirect_to @user }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    if current_user?(@user)
      flash[:danger] = "You cannot delete yourself!"
    else
      #
      # First we need to delete the pools owned by this user and associated
      # pool memberships
      #
      if @user.pools
        @user.pools.each do |pool|
          pool.remove_memberships
          pool.recurse_delete
        end
      end
      @user.destroy
      flash[:success] = "User deleted."
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.turbo_stream
      format.json
    end
  end

  def admin_add
    if current_user.admin?
      user = User.find_by_id(params[:id])
      user.update_attribute(:admin, "1")
      flash[:success] = "Admin status has been granted to User: '#{user.name}!"
    else
      flash[:danger] = "Only an Admin user can update admin status!"
    end
    redirect_to users_url
  end

  def admin_del
    if current_user.admin?
      user = User.find_by_id(params[:id])
      user.update_attribute(:admin, "0")
      flash[:success] = "Admin status has been removed from User: '#{user.name}!"
    else
      flash[:danger] = "Only an Admin user can update admin status!"
    end
    redirect_to users_url
  end

  # Render inline password form into the user's turbo frame
  def user_diagnostics
    user = User.find_by_id(params[:id])
    if user
      render turbo_stream: turbo_stream.replace(
        view_context.dom_id(user),
        partial: "diagnostics/user_password_form",
        locals: { user: user }
      )
    else
      head :not_found
    end
  end

  # Return just the user's row so it can replace the user's turbo frame (used for Cancel)
  def user_row
    user = User.find_by_id(params[:id])
    if user
      render turbo_stream: turbo_stream.replace(
        view_context.dom_id(user),
        partial: "diagnostics/user_tab_index",
        locals: { user: user }
      )
    else
      head :not_found
    end
  end

  # Handle POST from inline password form: set a chosen password via the Diagnostics service
  def user_diag_chg
    Rails.logger.info("user_diag_chg called by user=#{current_user&.id} params=#{params.to_unsafe_h}")
    service = Diagnostics::UsersDiagnostics.new
    commands = params[:commands] || ['user_pw']
    result = service.handle_change(params.merge(commands: commands))

    user = result[:user]
    # find the first command result for user_pw
    pw_result = result[:results]&.find { |r| r[:command] == 'user_pw' }

    Rails.logger.info("user_diag_chg result=#{result.inspect}")

    if pw_result && pw_result[:result][:status] == :ok
      flash[:success] = "Password updated for #{user.email}"

      actions = [
        turbo_stream.replace(view_context.dom_id(user), partial: "diagnostics/user_tab_index", locals: { user: user }),
        turbo_stream.replace("flash", partial: "layouts/flash")
      ]

      render turbo_stream: actions
    else
      # Attach errors to user if available so form can display them
      if pw_result && pw_result[:result][:errors]
        user.errors.add(:base, pw_result[:result][:errors].join(', '))
        flash[:danger] = pw_result[:result][:errors].join(', ')
      else
        flash[:danger] = 'Unable to update password'
      end

      actions = [
        turbo_stream.replace(view_context.dom_id(user), partial: "diagnostics/user_password_form", locals: { user: user }),
        turbo_stream.replace("flash", partial: "layouts/flash")
      ]

      render turbo_stream: actions, status: :unprocessable_entity
    end
  end

  # Setup to resend the activation email !!!! Is this still needed?
  # def resend_activation
  #  user = User.find_by_id(params[:id])
  #  if user.activated?
  #    flash[:notice] = "User account has already been activated!"
  #  else
  #    user.resend_activation
  #    flash[:success] = "Activate account message has been resent!"
  #  end
  #  redirect_to root_url
  # end

  private

    def user_params
      params.expect(user: [ :name, :user_name, :phone, :contact, :email, :password,
                                   :password_confirmation ])
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless @user == current_user
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = "Only an Admin User can access that page!"
        if request.format.turbo_stream?
          # Replace the global flash area so Turbo frame requests can display the error inline
          render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash"), status: :forbidden
        else
          redirect_to root_url
        end
      end
    end
end
