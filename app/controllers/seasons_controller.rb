class SeasonsController < ApplicationController

  def new
    @season = Season.new
    @season.year = Season.getSeasonYear
    @season.current_week = 1
  end

  def index
    @seasons = Season.paginate(page: params[:page])
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

  def edit
    @season = Season.find(params[:id])
  end

  def update
    @season = Season.find(params[:id])
    byebug
    if @season.update_attributes(season_params)
      flash[:success] = "Season updated."
      redirect_to @season
    else
      render 'edit'
    end
  end

  def show
    @season = Season.find_by_id(params[:id])
    if @season.nil?
      flash[:notice] = 'The season you tried to access does not exist'
      redirect_to seasons_path
    end
  end

  def destroy
    @season = Season.find(params[:id])
    if @season.nfl_league
      league = "NFL"
    else
      league = "NCAA"
    end
    @season = Season.find(params[:id])
    @season.destroy
    flash[:success] = "Successfully deleted #{league} Season for year '#{@season.year}'!"
    redirect_to seasons_path
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

end
