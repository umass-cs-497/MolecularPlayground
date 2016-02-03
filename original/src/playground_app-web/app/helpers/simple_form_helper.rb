module SimpleFormHelper

	# My customized version of simple_form_for...
	# Uses SimplerFormBuilder and makes the form horizontal
	# You can also give it a default span to use on input elements
	# It uses the SimplerFormBuilder.
	#
	def simpler_form_for(object, *args, &block)
		options = args.extract_options!
		options ||= {}
		span = options[:span] || nil
		unless span.nil?
			options.delete(:span)
			options.merge! defaults: { input_html: { class: "span#{span}" } }
		end
		options.merge! builder: SimplerFormBuilder
		options.merge! html: { class: 'form-horizontal' }
		simple_form_for(object, options, &block)
	end
end