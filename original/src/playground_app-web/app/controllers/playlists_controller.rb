class PlaylistsController < ApplicationController

	layout 'admin'

	before_filter :authenticate_user!
	load_and_authorize_resource :installation
	load_and_authorize_resource :playlist, through: :installation, except: [:index]
	add_breadcrumb 'Installations', :installations_path, except: [:select_scenes]
	before_filter :add_installation_breadcrumb, except: [:select_scenes]
	add_breadcrumb 'Playlists', :installation_playlists_path, except: [:select_scenes]
	before_filter :add_playlist_breadcrumb, only: [:show, :edit, :scenes]

	def index
		authorize! :index, Playlist
		@playlists = @installation.playlists
	end

	def new
		add_breadcrumb 'New', :new_installation_playlist_path
	end

	def create
		@playlist.installation = @installation
    if @playlist.save
      flash[:success] = "Playlist created"
      redirect_to installation_playlists_path(@installation)
    else
      add_breadcrumb 'New', new_installation_playlist_path(@installation)
      render 'new'
    end
	end

	def edit
		add_breadcrumb 'Edit', edit_installation_playlist_path(@installation, @playlist)
	end

	def update
	  if @playlist.update_attributes(params[:playlist])
      flash[:success] = "Playlist updated"
      redirect_to installation_playlist_path(@installation, @playlist)
    else
      add_breadcrumb 'Edit', edit_installation_playlist_path(@installation, @playlist)
      render 'edit'
    end
	end

  # Accessed via AJAX post when playlist item table row
  # is dragged and dropped
  def sort
    params[:playlist_item].each_with_index do |id, index|
      PlaylistItem.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

	def scenes
		add_breadcrumb 'Scenes', scenes_installation_playlist_path(@installation, @playlist)
	end

	def update_scenes

    # find the correct position so that added scenes are
    # placed at the end of the playlist
    max_position = 1
    unless @playlist.playlist_items.count == 0
      max_position = @playlist.playlist_items.maximum(:position) + 1
    end

    scenes = params[:scenes]
    unless scenes.nil?
      scenes.each do |scene_id|
        item = PlaylistItem.new(scene_id: scene_id, position: max_position)
        @playlist.playlist_items << item
        max_position += 1
      end
    end
    count = (scenes.nil?) ? 0 : scenes.count
    flash[:success] = "Added #{help.pluralize(count, 'scene')}."
    redirect_to scenes_installation_playlist_path(@installation, @playlist)
	end

	def select_scenes
		@scenes = Scene.find(:all)
		render partial: 'scene_modal'
	end

	def delete
		add_breadcrumb 'Delete', delete_installation_playlist_path(@installation, @playlist)
	end

	def destroy
		@playlist.destroy
		flash[:success] = "Playlist deleted"
		redirect_to installation_playlists_path(@installation)
	end

	private 

		def add_installation_breadcrumb
			add_breadcrumb @installation.name, installation_path(@installation)
		end

		def add_playlist_breadcrumb
			add_breadcrumb @playlist.name, installation_playlist_path(@installation, @playlist)
		end

end
