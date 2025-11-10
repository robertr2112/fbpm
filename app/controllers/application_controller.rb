class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  #allow_browser versions: :modern # disabled for causing timeout errors

  protect_from_forgery prepend: true, with: :exception
  before_action :set_pool_variable_default

  include SessionsHelper

  def redirect_to_back_or_default(default = root_url)
    redirect_back(fallback_location: default)
  end

  private

  def set_pool_variable_default
    @pool = nil
  end
end
