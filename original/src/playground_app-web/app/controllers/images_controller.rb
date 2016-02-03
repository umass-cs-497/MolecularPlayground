class ImagesController < ApplicationController

  def show
  	image = Image.find(params[:id])
  	send_data(image.data, filename: "#{params[:id]}.png") and return
  end

end
