class SeasonsController < ApplicationController
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
      render :new, status: :unprocessable_entity
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
      if @season.update(season_params)
        flash[:success] = "Season updated."
        redirect_to @season
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:danger] = "Cannot edit the Season after it has been marked Open!"
      redirect_to @season
    end
  end

  def show
    @season = Season.find_by_id(params[:id])
    if @season.nil?
      flash[:warning] = "The season you tried to access does not exist"
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
      flash[:danger] = "You cannot set the state to open until you have created at least the first week!"
      redirect_to @season
    elsif @season.weeks.count < @season.number_of_weeks
      flash[:danger] = "You cannot set the state to open until you have created all of the weeks"
      redirect_to @season
    else
      flash[:success] = "Successfully set the state to open!"
      @season.setState(Season::STATES[:Open])
      redirect_to @season
    end
  end

  def closed
    @season = Season.find_by_id(params[:id])
    if !@season.canBeClosed?
      flash[:danger] = "You cannot set the state to closed until all weeks have been marked final!"
      redirect_to @season
    else
      @season.setState(Season::STATES[:Closed])
      redirect_to @season
    end
  end

  def season_diagnostics
    @season = Season.find_by_id(params[:id])
    if @season.nil?
      flash[:danger] = "The season you tried to access does not exist"
      redirect_to seasons_path
    end
  end

  def season_diag_chg
    service = Diagnostics::SeasonDiagnostics.new
    season = service.handle_change(params.merge(id: params[:id]))
    redirect_to season_diagnostics_path(season)
  end

  private

    def season_params
      params.expect(season: [ :year, :nfl_league, :number_of_weeks, :current_week,
                                     weeks_attributes: [ :id, :season_id,
                                                       :week_number, :state, :_destroy,
                                     games_attributes: [ :id, :week_id, :homeTeamIndex,
                                                     :awayTeamIndex, :spread,
                                                     :homeTeamScore, :awayTeamScore,
                                                     :game_date, :_destroy ] ] ])
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = "Only an Admin User can access that page!"
        redirect_to current_user
      end
    end
end
