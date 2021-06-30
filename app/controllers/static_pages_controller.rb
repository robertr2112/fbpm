class StaticPagesController < ApplicationController
  def home
    # if the user is logged_in then redirect to their home page
    if logged_in?
      redirect_to current_user
    end
  end

  def contact
  end

  def about
  end

  def help
  end

end
