class TeamsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, except: [:index, :show]

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
        render 'edit'
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
    @teams = Team.where(nfl: true).paginate(page: params[:page], per_page: 11).order('name ASC')
  end

  private

    def team_params
      params.require(:team).permit(:name, :nfl,
                                   :imagePath)
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = 'Only an Admin User can access that page!'
        redirect_to current_user
      end
    end

end
