class TeamsController < ApplicationController
  before_action :admin_user, except: [ :index, :show ]

  def edit
    @team = Team.find_by_id(params[:id])
    if !@team
        flash[:danger] = "Cannot find Team with id #{params[:id]}!"
        redirect_to teams_path
    end
  end

  def update
    @team = Team.find_by_id(params[:id])
    if @team
      if @team.update(team_params)
        flash[:success] = "Team Info updated"
        redirect_to @team
      else
        render :edit, status: :unprocessable_entity
      end
    else
        flash[:danger] = "Cannot find Team with id #{params[:id]}!"
        redirect_to teams_path
    end
  end
  def show
    @team = Team.find_by_id(params[:id])
    if !@team
        flash[:danger] = "Cannot find Team with id #{params[:id]}!"
        redirect_to teams_path
    end
  end
  def index
    @pagy, @teams = pagy(Team.where(nfl: true), limit: 10)
  end

  private

    def team_params
      params.expect(team: [ :name, :nfl, :imagePath ])
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = "Only an Admin User can access that page!"
        redirect_to current_user
      end
    end
end
