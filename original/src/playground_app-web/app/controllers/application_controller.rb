class ApplicationController < ActionController::Base
  protect_from_forgery

  add_breadcrumb 'Home', :home_path

  rescue_from CanCan::AccessDenied do |exception|
  	flash[:error] = "Access denied!"
  	redirect_to root_path
  end

  def help
  	Helper.instance
  end

  class Helper
  	include Singleton
  	include ActionView::Helpers::TextHelper
  end

end
