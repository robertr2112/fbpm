require 'json'
class WeeksController < ApplicationController
  before_action :logged_in_user
  before_action :activated_user
  before_action :admin_user, except: [:show, :index]
  around_action :set_time_zone

  def new
    @season = Season.find_by_id(params[:season_id])
    if !@season.nil?
      @week = @season.weeks.new
      @game = @week.games.build
      if @season.weeks.order(:week_number).last.blank?
        @week.week_number = @season.current_week
      else
        @week.week_number = @season.weeks.order(:week_number).last.week_number + 1
      end
      if @week.week_number > @season.number_of_weeks
        flash[:danger] = "Cannot create week. This would exceed the number of weeks for this Season!"
        redirect_to @season
      end

    else
      flash[:danger] = "Cannot create week. Season with id:#{params[:season_id]} does not exist!"
      redirect_to seasons_path
    end
  end

  def create
    @season = Season.find_by_id(params[:season_id])
    if !@season.nil?
      @week = @season.weeks.new(week_params)
      if @season.weeks.order(:week_number).last.blank?
        @week.week_number = @season.current_week
      else
        @week.week_number = @season.weeks.order(:week_number).last.week_number + 1
      end
      @week.setState(Week::STATES[:Pend])
      if @week.save
        # Handle a successful save
        flash[:success] =
            "Week #{@week.week_number} for '#{@season.year}' was created successfully!"
        # Set the state to Pend
        redirect_to @week
      else
        render 'new'
      end
    else
      flash[:danger] = "Cannot create week. Season with id:#{params[:season_id]} does not exist!"
      redirect_to seasons_path
    end
  end

  # This route passes in the season_id so you can create the week for the specified
  # season.
  def auto_create
    season = Season.find_by_id(params[:id])
    if !season.nil?
      @week = season.weeks.create
      @week.setState(Week::STATES[:Pend])
      if season.weeks.order(:week_number).last.blank?
        @week.week_number = season.current_week
      else
        @week.week_number = season.weeks.order(:week_number).last.week_number + 1
      end
      if @week.week_number > season.number_of_weeks
        flash[:danger] = "Cannot create week! This would exceed the number of weeks for this Season!"
        redirect_to season
      end

    else
      flash[:danger] = "Cannot create week! Season with id:#{params[:season_id]} does not exist!"
      redirect_to seasons_path
    end

    # Using -e flag scrapes the ESPN website for schedule and -P mode runs it
    # in Production mode, not using Webdriver_manager.
    if Rails.env.production?
      nfl_games_json =
        `python lib/assets/python/nfl-scraper.py -eP -y "#{season.year}" -n "#{@week.week_number}"`
    else
      nfl_games_json =
        `python lib/assets/python/nfl-scraper.py -e -y "#{season.year}" -n "#{@week.week_number}"`
    end
    if nfl_games_json.include? "Exception"
      flash[:danger] = "Cannot create week! There was a problem contacting the website."
      redirect_to seasons_path
    else
      nfl_games = JSON.parse(nfl_games_json).with_indifferent_access
      @week.create_nfl_week(season, nfl_games["game"])
      if @week.save
        # Handle a successful save
        flash[:success] =
              "Week #{@week.week_number} for '#{season.year}' was created successfully!"
        redirect_to @week
      else
        render 'new'
      end
    end # if Exception
  end

  # This updates the games of the week to fix schedule changes in NFL games
  # (ie. flex scheduling)
  def update_games
    @week = Week.find_by_id(params[:id])
    if @week
      season = Season.find_by_id(@week.season_id)
      # Using -e flag scrapes the ESPN website for schedule and -P mode runs it
      # in Production mode, not using Webdriver_manager.
      if Rails.env.production?
        nfl_games_json =
          `python lib/assets/python/nfl-scraper.py -eP -y "#{season.year}" -n "#{@week.week_number}"`
      else
        nfl_games_json =
          `python lib/assets/python/nfl-scraper.py -e -y "#{season.year}" -n "#{@week.week_number}"`
      end
      if nfl_games_json.include? "Exception"
        flash[:danger] = "Cannot update games for week #{@week.week_number}. There was a problem contacting the website!"
        redirect_to @week  
      else
        nfl_games = JSON.parse(nfl_games_json).with_indifferent_access
        @week.create_nfl_week(season, nfl_games["game"])
        if @week.save
          # Handle a successful save
          flash[:success] =
                "The games for Week #{@week.week_number} were updated successfully!"
        else
          flash[:danger] =
                "The games for Week #{@week.week_number} were not updated!"
        end
        redirect_to @week
      end
    else
      flash[:danger] = "Cannot update games for week #{@week.week_number}. It does not exist!"
      redirect_to @week
    end
  end

  # This route passes the id of the week to update scores
  def add_scores
    @week = Week.find_by_id(params[:id])
    season = Season.find_by_id(@week.season_id)

    # Using -e flag scrapes the ESPN website for schedule and -P mode runs it
    # in Production mode, not using Webdriver_manager.
    if Rails.env.production?
      nfl_games_json =
        `python lib/assets/python/nfl-scraper.py -eP -y "#{season.year}" -n "#{@week.week_number}"`
    else
      nfl_games_json =
        `python lib/assets/python/nfl-scraper.py -e -y "#{season.year}" -n "#{@week.week_number}"`
    end
    # Rails.logger.info "nfl_games_json: #{nfl_games_json}"
    if nfl_games_json.include? "Exception"
      flash[:danger] = "Cannot update scores! There was a problem contacting the website."
    else
      nfl_games = JSON.parse(nfl_games_json).with_indifferent_access
      @week.add_scores_nfl_week(season, nfl_games["game"])
      flash[:success] =
      "The scores for Week #{@week.week_number} were updated successfully!"
    end
    redirect_to @week
   end


  def edit
    @week = Week.find_by_id(params[:id])
    @games = @week.games
    if @week.checkStateFinal
      flash[:warning] = "Can't Edit the week once it is in the Final state!"
      redirect_to @week
    end
  end

  def update
    @week = Week.find_by_id(params[:id])
    if @week.update_attributes(week_params)
      flash[:success] = "Successfully updated week #{@week.week_number}."
      redirect_to @week
    else
      render :edit
    end
  end

  def show
    @week = Week.find_by_id(params[:id])
    @season = Season.find_by_id(@week.season_id)
    @games = @week.games
  end

  def destroy
    @week = Week.find_by_id(params[:id])
    @season = Season.find_by_id(@week.season_id)
    if current_user.admin?
      if @week.deleteSafe?(@season)
        @week.destroy
        flash[:success] = "Successfully deleted Week '#{@week.week_number}'!"
        redirect_to @season
      else
        flash[:danger] = "Cannot delete Week '#{@week.week_number}' because it is not the last week!"
        redirect_to @week
      end
    else
      flash[:danger] = "Only an Admin user can delete weeks!"
      redirect_to @week
    end
  end

  def open
    @week = Week.find_by_id(params[:id])
    if @week.games.empty?
      flash[:danger] = "Week #{@week.week_number} is not ready to be Open! You need to enter games for this week!"
      redirect_to @week
    end
    @week.setState(Week::STATES[:Open])
    redirect_to @week
  end

  def closed
    @week = Week.find_by_id(params[:id])
    @week.setState(Week::STATES[:Closed])
    redirect_to @week
  end

  def final
    @week = Week.find_by_id(params[:id])
    if @week.checkStateFinal
        flash[:danger] = "Week #{@week.week_number} is already Final!"
        redirect_to @week
    else
      if weekFinalReady(@week)
        @week.setState(Week::STATES[:Final])
        # Update the entries status/totals based on this weeks results
        @season = Season.find_by_id(@week.season_id)
        @season.updatePools
        flash[:success] = "Week #{@week.week_number} is final!"
        redirect_to @week
      else
        flash[:danger] = "Week #{@week.week_number} is not ready to be Final.  Please ensure all scores have been entered."
        redirect_to @week
      end
    end
  end

  private
    def week_params
      params.require(:week).permit(:state, :week_number,
                                   games_attributes: [:id, :week_id,
                                                     :homeTeamIndex,
                                                     :awayTeamIndex,
                                                     :spread,
                                                     :homeTeamScore,
                                                     :awayTeamScore,
                                                     :game_date,
                                                     :_destroy] )
    end

    def set_time_zone
      Time.use_zone('Central Time (US & Canada)') { yield }
    end

    def weekFinalReady(week)
      games = week.games
      games.each do |game|
        if game.homeTeamScore == 0 && game.awayTeamScore == 0
          return false
        end
      end

      return true
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = 'Only an Admin User can access that page!'
        redirect_to current_user
      end
    end

end
