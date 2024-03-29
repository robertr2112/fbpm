class SeasonsController < ApplicationController
  before_action :logged_in_user
  before_action :activated_user
  before_action :admin_user

  def new
    @season = Season.new
    @season.year = Season.getSeasonYear
    @season.current_week = 1
  end

  def create
    @season = Season.create(season_params)
    if @season.id
      # Handle a successful save
      flash[:success] = "Season for year '#{@season.year}' was created successfully!"
      redirect_to @season
    else
      render 'new'
    end
  end

  def index
    @seasons = Season.paginate(page: params[:page])
  end

  def edit
    @season = Season.find_by_id(params[:id])
    if !@season.isPending?
      flash[:danger] = "Cannot edit the Season after it has been marked Open!"
      redirect_to @season
    end
  end

  def update
    @season = Season.find_by_id(params[:id])
    if @season.isPending?
      if @season.update_attributes(season_params)
        flash[:success] = "Season updated."
        redirect_to @season
      else
        render 'edit'
      end
    else
      flash[:danger] = "Cannot edit the Season after it has been marked Open!"
      redirect_to @season
    end
  end

  def show
    @season = Season.find_by_id(params[:id])
    if @season.nil?
      flash[:warning] = 'The season you tried to access does not exist'
      redirect_to seasons_path
    end
  end

  def index
    @seasons = Season.paginate(page: params[:page])
  end

  def destroy
    @season = Season.find_by_id(params[:id])
    if current_user.admin?
      # Before we recursively delete all children/grand-children of Season, we need to
      # remove the pool_membership tables for each pool.
      @season.pools.each do |pool|
        pool.remove_memberships
      end
      @season.recurse_delete
      if @season.nfl_league
        league = "NFL"
      else
        league = "NCAA"
      end
      flash[:success] = "Successfully deleted #{league} Season for year '#{@season.year}'!"
      redirect_to seasons_path
    else
      flash[:danger] = "Only an Admin user can delete the season!"
      redirect_to pools_path
    end
  end

  def open
    @season = Season.find_by_id(params[:id])
    if @season.weeks.empty?
      flash[:danger] = 'You cannot set the state to open until you have created at least the first week!'
      redirect_to @season
    elsif @season.weeks.count < @season.number_of_weeks
      flash[:danger] = 'You cannot set the state to open until you have created all of the weeks'
      redirect_to @season
    else
      flash[:success] = 'Successfully set the state to open!'
      @season.setState(Season::STATES[:Open])
      redirect_to @season
    end
  end

  def closed
    @season = Season.find_by_id(params[:id])
    if !@season.canBeClosed?
      flash[:danger] = 'You cannot set the state to closed until all weeks have been marked final!'
      redirect_to @season
    else
      @season.setState(Season::STATES[:Closed])
      redirect_to @season
    end
  end

  def season_diagnostics
    @season = Season.find_by_id(params[:id])
    if @season.nil?
      flash[:danger] = 'The season you tried to access does not exist'
      redirect_to seasons_path
    end
  end

  def season_diag_chg
    season = Season.find_by_id(params[:id])
    if season.nil?
      flash[:danger] = 'The season you tried to access does not exist'
      redirect_to seasons_path
    end

    # Change the current week
    if params[:cur_week]
      season.update_attribute(:current_week, params[:number])
      season.save
    end
    if params[:chg_week_state]
      week = Week.find_by_id(params[:week])
      week.update_attribute(:state, params[:state])
      week.save
    end
    if params[:update_nfl_team_info]
      # Need to update the Cincinnati info, and change St Louis to Los Angeles

      record = Team.find_by_name("Cinncinatti Bengals")
      if record
        record.name = "Cincinnati Bengals"
        record.save!
      end
      record = Team.find_by_name("St Louis Rams")
      if record
        record.name = "Los Angeles Rams"
        record.save!
      end

    end

    redirect_to season_diagnostics_path(season)
  end

  private

    def season_params
      params.require(:season).permit(:year, :nfl_league, :number_of_weeks, :current_week,
                                     weeks_attributes:[:id, :season_id,
                                                       :week_number, :state, :_destroy,
                                     games_attributes:[:id, :week_id, :homeTeamIndex,
                                                     :awayTeamIndex, :spread,
                                                     :homeTeamScore, :awayTeamScore,
                                                     :game_date, :_destroy ]] )
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = 'Only an Admin User can access that page!'
        redirect_to current_user
      end
    end

end
