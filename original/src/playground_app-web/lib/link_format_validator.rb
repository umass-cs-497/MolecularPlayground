class LinkFormatValidator < ActiveModel::EachValidator

	# This class is for validating that the given value is a valid URL,
	# starting with http:// or https://
	#
	# It is used in a validates call like this:
	# validates :home_page, link_format: true
	#
  def validate_each(object, attribute, value)
    unless value =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
      object.errors[attribute] << (options[:message] || "is not a valid URL")
    end
  end
end