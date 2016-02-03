class PlaylistItemsController < ApplicationController
	
	before_filter :authenticate_user!

	def destroy
		item = PlaylistItem.find(params[:id])
		playlist = item.playlist
		item.destroy
		flash[:success] = "#{item.title} removed from playlist."
		redirect_to scenes_installation_playlist_path(playlist.installation, playlist)
	end

end
