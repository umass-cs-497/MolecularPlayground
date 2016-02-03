module BootstrapHelper

	# BootstrapHelper exists to make it easier to generate
	# elements that use Twitter Bootstrap styles

	# Convenience method to render the breadcrumbs with 
	# Bootstrap's style
	def tbs_breadcrumbs
		render_breadcrumbs builder: ::BootstrapBreadcrumbsBuilder
	end

	# Wrapper for a set of Bootstrap tabs (see tbs_tab)
	def tbs_nav_tabs
		content_tag(:ul, class: 'nav nav-tabs') do
			yield
		end
	end

	# Generates a single Bootstrap-style li element for use
	# in a tab set. Should go in a tbs_nav_tabs block.
	def tbs_tab(path, title, icon)
		content_tag(:li, class: "#{title.parameterize.underscore}") do
			link_to path do
				content_tag(:i, '', class: "icon-#{icon}") + " #{title}"
			end
		end
	end

	# Use this function to set the active tab (based on title)
	# for the current page. Must be called after the tabs have been rendered
	def tbs_active_tab(title)
		content_tag(:script) do
			"$('.nav.nav-tabs li.active').removeClass('active');" +
			"$('.nav.nav-tabs li.#{title.parameterize.underscore}').addClass('active')"
		end
	end

	# Creates a button-styled link. Options can include size (e.g. 'large')
	# and style (e.g. 'success') and a bootstrap icon (e.g. 'eye-open')
	def tbs_button_link(title, path, options = {})
		btn_class = "btn"
		btn_class += " btn-#{options[:size]}" unless options[:size].nil?
		btn_class += " btn-#{options[:style]}" unless options[:style].nil?
		options.delete(:size)
		options.delete(:style)

		icon = options[:icon]
		options.delete(:icon)
		options.merge! class: btn_class

		if icon.nil?
			link_to title, path, options
		else
			link_to path, options do
				content_tag(:i, nil, class: "icon-#{icon} icon-white") + " #{title}"
			end
		end
	end



end