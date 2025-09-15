class EntriesController < ApplicationController
  before_action :logged_in_user
  before_action :activated_user

  def new
    @pool = Pool.find_by_id(params[:pool_id])
    if !@pool.nil?
      if @pool.allowMulti
        if @pool.isOpen?
          @entry = @pool.entries.new
          entry_name = @pool.getEntryName(current_user)
          @entry.name = entry_name
        else
          flash[:danger] = "This pool is closed for new entries!"
          redirect_to @pool
        end
      else
        flash[:danger] = "This pool does not allow multiple entries for a user!"
        redirect_to @pool
      end
    else
        flash[:danger] =
          "Couldn't create entry. Pool with id: #{params[:pool_id]} doesn't exist!"
        redirect_to pools_path
    end
  end

  def create
    @pool = Pool.find_by_id(params[:pool_id])
    @entry =
      @pool.entries.create(entry_params.merge(user_id: current_user.id,
                                             survivorStatusIn: true,
                                             supTotalPoints: 0))
    if @entry.id
      flash[:success] = "Entry: #{@entry.name} was created successfully!"
      redirect_to @pool
    else
      render 'new'
    end
  end

  def edit
    @entry = Entry.find_by_id(params[:id])
    @pool = Pool.find_by_id(@entry.pool_id)
  end

  def update
    @entry = Entry.find_by_id(params[:id])
    @pool = Pool.find_by_id(@entry.pool_id)
    if @entry.update(entry_params)
      flash[:success] = "Entry updated"
      redirect_to @pool
    else
      render 'edit'
    end
  end

  def destroy
    @entry = Entry.find_by_id(params[:id])
    @pool = Pool.find_by_id(@entry.pool_id)
    if @entry
      if @entry.picks.empty?
        @entry.destroy
        flash[:success] = "Entry: #{@entry.name} was deleted successfully!"
        redirect_to @pool
      else
        flash[:danger] = "Entry can't be deleted after picks have been made!"
      end
    else
      flash[:danger] = "Could not find Entry with id: #{:id} !"
    end
  end

  private
    def entry_params
      params.require(:entry).permit(:name, :survivorStatusIn, :supTotalPoints)
    end
end
