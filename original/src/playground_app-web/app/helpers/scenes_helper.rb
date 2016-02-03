module ScenesHelper

	# This helper will return the url to the main script if it exists
	# otherwise it will return the simple script url
	#
	def scene_main_script_url(scene)
		if scene.main_script.present?
			scene_file_data_url(scene, scene.main_script.filename)
		else
			scene_simple_script_url(scene)
		end
	end

	# Easy way to get a path to an (unprocessed) data file
	#
	def raw_data_path(data_file)
		scene_file_data_path(data_file.scene, data_file.filename, raw: 'raw')
	end

end
