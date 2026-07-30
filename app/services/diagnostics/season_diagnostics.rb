# Service object to encapsulate Season diagnostics logic
module Diagnostics
  class SeasonDiagnostics
    def initialize(params = {})
      @params = params
    end

    # Handle the actions currently implemented in SeasonsController#season_diag_chg
    # Returns the affected Season
    def handle_change(params)
      season = Season.find_by_id(params[:id] || params[:season_id])
      raise ActiveRecord::RecordNotFound unless season

      # Change the current week
      if params[:cur_week]
        season.update!(current_week: params[:number])
      end

      # Change a week's state
      if params[:chg_week_state]
        week = Week.find_by_id(params[:week])
        week.update!(state: params[:state]) if week
      end

      # Misc team name fixes
      if params[:update_nfl_team_info]
        record = Team.find_by_name("Cinncinatti Bengals")
        record.update!(name: "Cincinnati Bengals") if record
        record = Team.find_by_name("St Louis Rams")
        record.update!(name: "Los Angeles Rams") if record
      end

      season
    end
  end
end
