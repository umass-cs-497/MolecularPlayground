class ScriptFileInput < SimpleForm::Inputs::FileInput

	# This is a simple_form input helper for creating a file input
	# that includes a [clear] link for clearing the current selection.
	#
	# Currently there is a separate version for model files and script
	# files, which should probably be combined into one. Some external
	# javascript is also required to make everything work...
	#
  def input
    template.content_tag(:span, super, id: 'script-input') +
    template.link_to('[clear]', '#', id: 'clear-script')
  end
end