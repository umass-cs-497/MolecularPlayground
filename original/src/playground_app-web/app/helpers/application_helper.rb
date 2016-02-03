module ApplicationHelper

	# This function produces a nice underlined page header/title
	#
	def page_header(title)
		content_tag(:div, class: 'page-header') do
			content_tag(:h1, title)
		end
	end

	# This function produces a Bootstrap-style closeable alert box
	# with the text given in value and style given by key
	#
	# For, example alert_box('Warning! Something bad happened', 'danger')
	# produces a red alert box with the specified text
	#
	def alert_box(value, key='success')
		content_tag(:div, class: "alert alert-#{key}") do
			link_to('&times;'.html_safe, '#', class: 'close', data: { dismiss: 'alert' }) +
			value
		end
	end

end
