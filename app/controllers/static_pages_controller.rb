class StaticPagesController < ApplicationController
  allow_unauthenticated_access only: [ :home ]
  before_action :resume_session, only: [ :home ]
  def home
    # if the user is logged_in then redirect to their home page
    if authenticated?
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
