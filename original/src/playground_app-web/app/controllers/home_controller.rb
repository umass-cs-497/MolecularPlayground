class HomeController < ApplicationController
	
	layout 'admin'

	before_filter :authenticate_user!

	def index
	end

	def installations
	end

	def queue
	end

	def settings
	end

	def update_settings
	end

end
