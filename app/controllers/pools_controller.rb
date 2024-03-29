class PoolsController < ApplicationController
  before_action :logged_in_user
  before_action :activated_user
  before_action :admin_user, only: [:pool_diagnostics, :pool_diag_chg ]

  def new
    year = Season.getSeasonYear

    # !!!! This code breaks once the college pools are added
    season = Season.where(year: year, nfl_league: true).first
    if season && season.isOpen?
      @pool = current_user.pools.new
      @pool_edit_flag = false
      current_week = season.getCurrentWeek
      if current_week.checkStateClosed || current_week.checkStateFinal
        @pool.starting_week = current_week.week_number + 1
      else
        @pool.starting_week = current_week.week_number
      end
    else
      flash[:danger] = "Cannot create a pool because the #{year} season is not ready for pools!"
      redirect_to_back_or_default(pools_path)
    end
  end

  def create
    # Get either the NFL or college season
    year = Season.getSeasonYear
    if Pool.typeSUP?(pool_params[:poolType])
      season = Season.where(year: year, nfl_league: false).first
    else
      season = Season.where(year: year, nfl_league: true).first
    end

    if season && season.isOpen?
      # If the season is setup then create the pool.
      current_week = season.getCurrentWeek
      @pool = current_user.pools.create(pool_params.merge(season_id: season.id))
      if @pool.id
        # create entry for owner of pool
        entry_name = @pool.getEntryName(current_user)
        new_entry_params = { name: entry_name }
        @pool.entries.create(new_entry_params.merge(user_id: current_user.id))
        # Handle a successful save
        flash[:success] = "Pool '#{@pool.name}' was created successfully!"
        # Set the ownership in PoolMembership.owner
        @pool.setOwner(current_user, true)
        redirect_to @pool
      else
        render 'new'
      end
    else
      flash[:danger] = "Cannot create a pool because the #{year} season is not ready for pools!"
      redirect_to pools_path
    end
  end

  def join
    # Test to make sure User is not already a member of this pool
    @pool = Pool.find_by_id(params[:id])
    if @pool.isMember?(current_user)
      flash[:warning] = "Already a member of Pool '#{@pool.name}'!"
      redirect_to @pool
    else
      if @pool.isOpen?
        @pool.addUser(current_user)
        flash[:success] = "Successfully added to Pool '#{@pool.name}'!"
        redirect_to @pool
      else
        flash[:danger] = "Sorry, but the pool is closed. Couldn't be added to Pool '#{@pool.name}'!"
        redirect_to @pool
      end
    end
  end

  def leave
    @pool = Pool.find_by_id(params[:id])
    if @pool.isOwner?(current_user)
      flash[:danger] = "Owner cannot leave the pool!"
      redirect_to @pool
    elsif !@pool.isMember?(current_user)
      flash[:danger] = "Not a member of Pool '#{@pool.name}'!"
      redirect_to pools_path
    else
      if @pool.isOpen?
        @pool.removeUser(current_user)
        flash[:success] = "Successfully removed from Pool '#{@pool.name}'!"
        redirect_to pools_path
      else
        flash[:danger] = "Sorry, but the pool is closed. Cannot be removed from Pool '#{@pool.name}'!"
        redirect_to @pool
      end
    end
  end

  def index
    if params[:year]
      @season = Season.find_by_year(params[:year])
    else
      year = Season.getSeasonYear
      @season = Season.where(year: year, nfl_league: true).first
    end
    if @season
      @pools = Pool.where(season_id: @season.id).paginate(page: params[:page])
    else
      flash[:danger] = "Cannot find a season to show pools!"
      redirect_back(fallback_location: root_path)
    end
  end

  def show
    @pool = Pool.find_by_id(params[:id])
    if @pool.nil?
      flash[:warning] = 'The pool you tried to access does not exist'
      redirect_to pools_path
    else
      @pools = @pool.users.paginate(:page => params[:page])
      @season = Season.find_by_id(@pool.season_id)
      @current_week = @pool.getCurrentWeek
    end
  end

  def edit
    @pool = Pool.find_by_id(params[:id])
    if @pool
      @season = Season.find_by_id(@pool.season.id)
      if @season.getCurrentWeek.week_number > 1
        @pool_edit_limited = true
      else
        @pool_edit_limited = false
      end
      @pool_edit_flag = true

      if !@pool.isOwner?(current_user)
        flash[:danger] = "Only the owner can edit the pool!"
        redirect_to pools_path
      end
    else
        flash[:danger] = "Cannot find Pool with id #{params[:id]}!"
        redirect_to pools_path
    end
  end

  def update
    @pool = Pool.find_by_id(params[:id])
    if @pool.isOwner?(current_user)
      if @pool.update_attributes(pool_params)
        flash[:success] = "Pool updated."
        redirect_to @pool
      else
        render 'edit'
      end
    else
      flash[:danger] = "Only the owner can edit the pool!"
      redirect_to pools_path
    end
  end

  def destroy
    @pool = Pool.find_by_id(params[:id])
    if @pool.isOwner?(current_user)
      @pool.remove_memberships
      @pool.recurse_delete
      flash[:success] = "Successfully deleted Pool '#{@pool.name}'!"
      redirect_to pools_path
    else
      flash[:danger] = "Only the onwer can delete the pool!"
      redirect_to pools_path
    end
  end

  def pool_diagnostics
    @pool = Pool.find_by_id(params[:id])
    if @pool
      @season = Season.find_by_id(@pool.season.id)
    else
      flash[:danger] = "Cannot find Pool with id #{params[:id]}!"
      redirect_to pools_path
    end
  end

  # This action receives multiple args.  The first is the pool, and the second is the action to do, the third is any other pertinent info
  def pool_diag_chg
    if params[:surv]
      entry = Entry.find_by_id(params[:entry_id])
      pool = Pool.find_by_id(entry.pool_id)
      if entry.survivorStatusIn
        value = false
      else
        value = true
      end
      entry.update_attribute(:survivorStatusIn, value)
      entry.save
    elsif params[:pool_status]
      pool = Pool.find_by_id(params[:pool_id])
      if pool.pool_done
        pool_done = false
      else
        pool_done = true
      end
      pool.update_attribute(:pool_done, pool_done)
      pool.save
    end
    redirect_to pool_diagnostics_path(pool)
  end

  private

    def pool_params
      params.require(:pool).permit(:name, :poolType, :allowMulti,
                                   :isPublic, :starting_week, :password)
    end

    def authenticate
      deny_access unless logged_in?
    end

    # Before filters
    def admin_user
      if !current_user.admin?
        flash[:danger] = 'Only an Admin User can access that page!'
        redirect_to current_user
      end
    end

end
