require "helpers/compatibility_helper"

module BuoyMultimediaHelper
	include BuoyCompatibilityHelper

	def svg_image(filename, alt, other_properties = '')
		"<img src=\"#{filename}.#{capable_of(:svg) ? 'svg' : 'png'}\" alt=\"#{alt}\" #{other_properties.present? ? ' ' + other_properties : ''}/>".html_safe
	end
end
