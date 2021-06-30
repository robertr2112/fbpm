class WeeksController < ApplicationController
  before_action :logged_in_user
  before_action :confirmed_user
  before_action :admin_user, except: [:show, :index]

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

  def auto_create
    season = Season.find_by_year(Time.now.year)
    if !season.nil?
      @week = season.weeks.create
      @week.setState(Week::STATES[:Pend])
      if season.weeks.order(:week_number).last.blank?
        @week.week_number = season.current_week
      else
        @week.week_number = season.weeks.order(:week_number).last.week_number + 1
      end
      if @week.week_number > season.number_of_weeks
        flash[:danger] = "Cannot create week. This would exceed the number of weeks for this Season!"
        redirect_to season
      end

    else
      flash[:danger] = "Cannot create week. Season with id:#{params[:season_id]} does not exist!"
      redirect_to seasons_path
    end

    @week.save
    @week.create_nfl_week
    if @week.save
      # Handle a successful save
      flash[:success] =
            "Week #{@week.week_number} for '#{season.year}' was created successfully!"
      redirect_to @week
    else
      render 'new'
    end
  end

  def add_scores
    @week = Week.find_by_id(params[:id])
    season = Season.find_by_id(@week.season_id)

    @week.add_scores_nfl_week

    redirect_to @week
  end


  def edit
    @week = Week.find_by_id(params[:id])
    @games = @week.games
    if @week.checkStateOpen || @week.checkStateFinal
      if @week.checkStateOpen
        flash[:warning] = "Can't Edit the scores for the week until it is in the Closed state!"
      else
        flash[:warning] = "Can't Edit the week once it is in the Final state!"
      end
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
        redirect_to seasons_path
      else
        flash[:danger] = "Cannot delete Week '#{@week.week_number}' because it is not the last week!"
        redirect_to @week
      end
    else
      flash[:danger] = "Only an Admin user can delete weeks!"
      redirect_to seasons_path
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
        flash[:warning] = "Week #{@week.week_number} is final!"
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
