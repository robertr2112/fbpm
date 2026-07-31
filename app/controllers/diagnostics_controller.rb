# app/controllers/diagnostics_controller.rb
# app/controllers/diagnostics_controller.rb
class DiagnosticsController < ApplicationController
  before_action :require_admin

  def index
  end

  def users
    @users = User.all
    render turbo_stream: turbo_stream.replace(
      "diagnostics-users-pane",
      partial: "diagnostics/users_tab",
      locals: { users: @users }
    )
  end

  def pools
    @pools = Pool.all
    render turbo_stream: turbo_stream.replace(
      "diagnostics-pools-pane",
      partial: "diagnostics/pools_tab",
      locals: { pools: @pools }
    )
  end

  def weeks
    @weeks = Week.all
    render turbo_stream: turbo_stream.replace(
      "diagnostics-weeks-pane",
      partial: "diagnostics/weeks_tab",
      locals: { weeks: @weeks }
    )
  end

  private

  def require_admin
    redirect_to root_path unless current_user&.admin?
  end
end
