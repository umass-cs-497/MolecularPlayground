class InstallationsController < ApplicationController

  layout 'admin'

  before_filter :authenticate_user!
  add_breadcrumb 'Installations', :installations_path
  load_and_authorize_resource except: [:index]
  before_filter :load_breadcrumb, only: [:show, :edit, :update, :delete]

  def index
    authorize! :index, Installation
    @installations = Installation.all
  end

  def show
  end

  def create
    if @installation.save
      flash[:success] = "Installation created"
      redirect_to installations_path
    else
      add_breadcrumb 'New', new_installation_path
      render 'new'
    end
  end

  def new
    add_breadcrumb 'New', :new_installation_path
  end

  def edit
    add_breadcrumb 'Edit', edit_installation_path(@installation)
  end

  def update
    if @installation.update_attributes(params[:installation])
      flash[:success] = "Installation updated"
      redirect_to @installation
    else
      add_breadcrumb 'Edit', edit_installation_path(@installation)
      render 'edit'
    end
  end

  # This one shows the delete confirmation
  def delete
    add_breadcrumb 'Delete', delete_installation_path(@installation)
  end

  # This one does the deleting
  def destroy
    @installation.destroy
    flash[:success] = "Installation deleted"
    redirect_to installations_path
  end

  private

    def load_breadcrumb
      add_breadcrumb @installation.name, installation_path(@installation)
    end
end