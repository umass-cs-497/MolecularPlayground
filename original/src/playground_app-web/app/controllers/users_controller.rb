class UsersController < ApplicationController

	layout 'admin'

	before_filter :authenticate_user!
	add_breadcrumb 'Users', :users_path
	load_and_authorize_resource except: [:index]
	before_filter :load_breadcrumb, only: [:show, :edit, :update, :password, :roles, :delete]

	def index
		authorize! :index, User
		@users = User.all
	end

	def show
	end

	def edit
		add_breadcrumb 'Edit profile', edit_user_path(@user)
	end

	def update
		if @user.update_attributes(params[:user])
			flash[:success] = 'User updated'
			redirect_to @user
		else
			add_breadcrumb 'Edit profile', edit_user_path(@user)
			render 'edit'
		end
	end

	def new
		add_breadcrumb 'New', :new_user_path
	end

	def create
		@user.skip_confirmation!
		if @user.save
      flash[:success] = "User created"
      redirect_to users_path
    else
    	add_breadcrumb 'New', :new_user_path
      render 'new'
    end
	end

	# Action for displaying password change page
	#
	def password
		add_breadcrumb 'Change password', change_password_path(@user)
		render 'password'
	end

	# Action for updating password. Current password must be provided
	#
	def update_password
		if @user.update_with_password(params[:user])
			sign_in(@user, bypass: true)
			flash[:success] = 'Password updated'
			redirect_to @user
		else
			render 'password'
		end
	end

	# Action for displaying current roles
	#
	def roles
		add_breadcrumb 'Edit roles', edit_roles_path(@user)
	end

	# Action for updating roles
	#
	def update_roles
		@user.admin = params[:user][:admin]
		installations = []
		params[:user][:installation_ids].each do |installation_id|
			installations << Installation.find(installation_id) unless installation_id.blank?
		end
		@user.installations = installations
		@user.save

		flash[:success] = 'Roles updated'
		redirect_to user_path(@user)
	end

	# Confirms deletion
	#
	def delete
		add_breadcrumb 'Delete', delete_user_path(@user)	
	end

	# Deletes the thing
	#
	def destroy
		@user.destroy
		flash[:success] = "User deleted"
		redirect_to users_path
	end

	private
		def load_breadcrumb
			add_breadcrumb @user.full_name, user_path(@user)
		end

end
