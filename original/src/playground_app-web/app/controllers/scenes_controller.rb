class ScenesController < ApplicationController
	include ImportHelper
	include ScenesHelper
	layout 'admin'

	before_filter :authenticate_user!, except: [:preview, :data, :simple_script]
	add_breadcrumb 'Scenes', :scenes_path
	load_and_authorize_resource except: [:index, :create, :import]
	before_filter :load_breadcrumb, only: [:show, :edit, :files, :green, :delete]

	def index
		authorize! :index, Scene
		@scenes = Scene.all
	end

	def show
	end

	def new
		add_breadcrumb 'New', :new_scene_path
	end

	def create
		authorize! :create, Scene

		# Can't mass assign model/script, so get the info
		# and delete it from the params hash
		#
		model_params = params[:scene][:model]
		params[:scene].delete(:model)

		script_params = params[:scene][:script]
		params[:scene].delete(:script)

		@scene = Scene.new(params[:scene])
		@scene.author = current_user
		if @scene.save

			model_file = read_file(model_params, @scene.id, ContentType::Model)
			script_file = read_file(script_params, @scene.id, ContentType::Script)

			@scene.main_script = script_file
			@scene.main_model = model_file
			@scene.save

			flash[:success] = 'Scene created'
			redirect_to edit_scene_path(@scene)
		else
			add_breadcrumb 'New', :new_scene_path
			render 'new'
		end
	end

	def edit
		add_breadcrumb 'Edit', edit_scene_path(@scene)
	end

	def update

		# get the model/script info 
		# and delete it from the params hash
		#
		model_params = params[:scene][:model]
		params[:scene].delete(:model)

		script_params = params[:scene][:script]
		params[:scene].delete(:script)

		@scene.update_attributes(params[:scene])
		if @scene.save

			unless model_params.nil?
				model_file = read_file(model_params, @scene.id, ContentType::Model)
				@scene.main_model = model_file
			end

			unless script_params.nil?
				script_file = read_file(script_params, @scene.id, ContentType::Script)
				@scene.main_script = script_file
			end

			# if either file was checked for removal
			# then delete it!
			#
			params[:data_files].each do |file_id|
				DataFile.find(file_id).destroy
			end unless params[:data_files].nil?

			@scene.save

			flash[:success] = 'Scene updated'
			redirect_to edit_scene_path(@scene)
		else
			add_breadcrumb 'Edit', edit_scene_path(@scene)
			render 'edit'
		end
	end

	# Confirms deletion
	#
	def delete
		add_breadcrumb 'Delete', delete_scene_path(@scene)
	end

	# Actually deletes the thing!
	#
	def destroy
	  @scene.destroy
    flash[:success] = "Scene deleted"
    redirect_to scenes_path
	end

	# Action for displaying list of all models/scripts in the scene
	#
	def files
		add_breadcrumb 'Files', files_scene_path(@scene)
	end

	# Action for uploading additional model/script and deleting any checked items
	#
	def update_files

		# Upload specified files (if any)
		#
		unless params[:files].nil?
			model_file = read_file(params[:files][:model_file], @scene.id, ContentType::Model)
			script_file = read_file(params[:files][:script_file], @scene.id, ContentType::Script)
		end

		# Delete any files that were checked
		#
		params[:data_files].each do |file_id|
			DataFile.find(file_id).destroy
		end unless params[:data_files].nil?

		flash[:success] = 'Files updated'

		redirect_to files_scene_path(@scene)
	end

	# Action for displaying Jmol applet preview of the scene
	# If a 'green' param is present, it will load a preview
	# of just the script associated with that green link
	#
	def preview
		if params[:green].present?
			green_link = GreenLink.find(params[:green])
			@script_url = scene_file_data_url(@scene, green_link.script_file.filename)
		else
			@script_url = scene_main_script_url(@scene)
		end
		render 'preview', layout: false
	end

	# Action for providing access to data files in this scene
	#
	# Can be accessed as /scenes/:id/data/filename.ext
	# Scripts are preprocessed to include MP constants unless
	# the raw param is set in the query.
	#
	# Model files are always sent as is.
	#
	def data
		data_file = DataFile.find_by_scene_id_and_filename(@scene, params[:filename])
		if data_file && data_file.content_type == ContentType::Script && params[:raw].nil?
			script_text = "PlaygroundProjection = true;" +
										"PlaygroundSupportScriptPath = \"/\";\n" +
										"PlaygroundFilePath = \"" + scene_file_data_url(@scene, '') + "\";\n" +
										data_file.data
			send_data(script_text, filename: data_file.filename) and return
		else
			send_data(data_file.data, filename: data_file.filename) and return
		end
	end

	# Action generates a simple script that makes the main model
	# spin for 45 seconds. 
	# This allows for scenes without any user-provided scripts at all.
	#
	def simple_script
		script_text = "load #{scene_file_data_url(@scene, @scene.main_model.filename)}\n" +
									"spin on\ndelay 45\nmessage 'MP_DONE';"
		send_data(script_text, filename: 'simple.spt') and return
	end

	# Starting point for importing a proteopedia scene
	#
	def import
		add_breadcrumb 'Import', import_path
	end

	def create_import
		require('open-uri')
		proto_url = params[:import][:url].dup

		# Make sure the URL looks reasonable
		#
		page_check = proto_url[/^http:\/\/(www\.)?proteopedia.org\/wiki\/index.php\//]
		if page_check.nil?
			flash.now[:error] = 'Invalid Proteopedia URL'
			add_breadcrumb 'Import', import_path
			render 'import' and return
		end

		# Fetch the Proteopedia page and get the green links
		# based on the article ID
		page = open(proto_url).read
		article_id = page[/var wgArticleId = \"(.*)\";/,1]
		green_links = green_from_xml(article_id)

		# Get the page title for our banner text
		#
		banner_text = page[/var wgTitle = \"(.*)\";/,1]

		# We can't make a scene without some green links
		#
		unless green_links.any?
			flash.now[:error] = 'No green links on the page'
			render 'import' and return
		end

		# Get the scene title from the URL
		#
		proto_url[/^http:\/\/(www\.)?proteopedia.org\/wiki\/index.php\//] = ""
		scene_title = proto_url

		new_scene = Scene.new
		Scene.transaction do

			# Make the new scene
			#
			new_scene.author = current_user
			new_scene.title = scene_title
			new_scene.first_banner = banner_text
			new_scene.description = 'Imported from Proteopedia'
			new_scene.web_link = params[:import][:url]
			new_scene.save!

			# The main script will call individual scripts
			# corresponding to each green link
			#
			main_script = DataFile.new
			main_script.filename = 'main.spt'
			main_script.content_type = ContentType::Script
			main_script.scene = new_scene
			main_script.data = ''


			# Keep a record of the models we've downloaded
			# so we don't end up with duplicates
			#
			model_hash = {}

			# download the model and state script
			# for each green link
			#
			green_links.each_with_index do |green_info, index|

				green_link = GreenLink.new
				green_link.position = index
				green_link.active = true
				green_link.title = green_info[:title]
				green_link.scene = new_scene

				# Download preview image
				#
				image = Image.new
				image.data = open(green_info[:png]).read
				image.save!
				green_link.image = image

				# Change the proteopedia path to a MP path
				#
				state_data = open(green_info[:url]).read
				#model_path = state_data[/\sload \/\*file\*\/\"(.*)\";/,1]
				model_code = state_data[/\sloadedfileprev = \"(.*)\";/,1]
				state_data.gsub!(/exit;\n/, '')
				#state_data[/exit;/] = ''
				state_data[/\sload \/\*file\*\/(.*)/] = "modelFile = PlaygroundFilePath + \"#{model_code}.gz\";\nload @modelFile;"

				script_file = DataFile.new
				script_file.data = state_data
				script_file.content_type = ContentType::Script
				script_file.filename = "#{index}.spt"
				script_file.scene = new_scene
				script_file.save!

				if model_hash[model_code].nil?
					model_url = 'http://www.proteopedia.org/cgi-bin/getfrozenstructure?' + model_code
					model_data = open(model_url).read

					model_file = DataFile.new
					model_file.data = model_data
					model_file.content_type = ContentType::Model
					model_file.filename = "#{model_code}.gz"
					model_file.scene = new_scene
					model_file.save!
					model_hash[model_code] = model_file
				else
					model_file = model_hash[model_code]
				end

				green_link.script_file = script_file
				green_link.model_file = model_file
				green_link.save!

				main_script.data << "scriptFile = PlaygroundFilePath + \"#{index}.spt\"\n script @scriptFile\ndelay 20;\n"
			end

			main_script.data << 'message "MP_DONE";'
			main_script.save!
			new_scene.main_script = main_script
			new_scene.save!

		end

		redirect_to edit_scene_path(new_scene)

	end

	# This action displays the sortable list of green links
	#
	def green
		add_breadcrumb 'Green links', green_scene_path(@scene)
	end

	# This action updates the position/active status of each
	# green link in the scene based on the user's edits
	#
	def update_green

		main_script = @scene.main_script
		main_script.data = ''

		params[:position].each_with_index do |link_id, index|
			green_link = GreenLink.find(link_id)
			green_link.position = index

			if params[:active].include?(link_id)
				green_link.active = true
				main_script.data << "scriptFile = PlaygroundFilePath + \"#{green_link.script_file.filename}\"\n script @scriptFile\ndelay 20;\n"
			else
				green_link.active = false
			end

			green_link.save!
		end

		main_script.data << 'message "MP_DONE";'
		main_script.save

		redirect_to green_scene_path(@scene)
	end

	private

		def load_breadcrumb
			add_breadcrumb @scene.title, scene_path(@scene)
		end

		# Reads a data file from the param hash and saves it
		#
		def read_file(file_info, scene_id=0, content_type=ContentType::Model)
			unless file_info.nil?
				data_file = DataFile.new
				data_file.scene_id = scene_id
				data_file.content_type = content_type
				data_file.filename = file_info.original_filename
				data_file.data = file_info.read
				data_file.save
			end
			data_file
		end

end
