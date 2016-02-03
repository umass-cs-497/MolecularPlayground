class StaticPagesController < ApplicationController
  def home
  	redirect_to home_path if user_signed_in?
  end

  def help
  end

  def contact
  end
end
