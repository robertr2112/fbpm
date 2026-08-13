# Service object to encapsulate User diagnostics logic
module Diagnostics
  class UsersDiagnostics
    def initialize(params = {})
      @params = params
    end

    # Prepare data for the diagnostics view
    # Returns a hash with :user
    def show(user)
      { user: user }
    end

    # Handle change actions for diagnostics users page
    # Accepts params and can process multiple commands provided via `params[:commands]` (Array or comma-separated String)
    # Supports the `user_pw` command to set a user's password. Password value is expected in params[:user][:password]
    # Returns a result hash including :user and :status (:ok or :error) and :errors when applicable
    def handle_change(params)
      @params = params
      user = User.find_by_id(params[:id] || params[:user_id])
      return { status: :error, error: "user_not_found" } unless user

      commands = extract_commands(params)
      result = { user: user, results: [] }

      commands.each do |cmd|
        case cmd.to_s
        when 'user_pw'
          res = handle_user_pw(user, params)
          result[:results] << { command: 'user_pw', result: res }
        else
          result[:results] << { command: cmd.to_s, result: { status: :ignored, reason: 'unknown_command' } }
        end
      end

      result
    end

    private

    def extract_commands(params)
      cmds = params[:commands] || []
      if cmds.is_a?(String)
        cmds = cmds.split(',').map(&:strip)
      end
      Array(cmds)
    end

    # Handle setting a user's password. It uses the same save approach as RegistrationsController#create
    # Expects password in params[:user][:password] or params[:password]
    def handle_user_pw(user, params)
      password = params.dig(:user, :password) || params[:password]
      password_confirmation = params.dig(:user, :password_confirmation) || params[:password_confirmation]

      if password.blank?
        return { status: :error, errors: ['password_blank'] }
      end

      # Assign and save using same pattern as registration: set attributes then save
      user.password = password
      user.password_confirmation = password_confirmation
      if user.save
        { status: :ok }
      else
        { status: :error, errors: user.errors.full_messages }
      end
    end
  end
end
