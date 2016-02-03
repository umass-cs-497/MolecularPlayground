class SimplerFormBuilder < SimpleForm::FormBuilder

	# This version of input allows a Bootstrap span number
	# to be provided without a ton of extra markup
	#
	# This builder is used by the simpler_form_for function
	# defined in helpers/simple_form_helper.rb
	#
	def input(attribute_name, options = {}, &block)
		span = options[:span] || nil
		unless span.nil?
			options.delete(:span)
			options[:input_html] ||= {}
			options[:input_html].merge! class: "span#{span}"
		end
		super(attribute_name, options, &block)
	end
end