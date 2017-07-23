require "helpers/compatibility_helper"

module BumbleberryMultimediaHelper
	include BumbleberryCompatibilityHelper

	def svg_image(filename, alt, other_properties = '')
		file = "#{filename}.svg"
		if !capable_of(:svg)
			# maybe we can convert these on the fly in the future?
			svg_file = file
			file = "#{filename}.png"
		end
		"<img src=\"#{image_path(file)}\" alt=\"#{alt}\" #{other_properties.present? ? ' ' + other_properties : ''}/>".html_safe
	end

	def svg(filename, alt, other_properties = '')
		if capable_of(:svg)
			return File.read(File.join(Rails.public_path, ActionController::Base.helpers.asset_path("#{filename}.svg"))).html_safe
		end
		ext = 'png'
		if !capable_of(:png_alpha) && File.exists?(File.join(Rails.public_path, ActionController::Base.helpers.asset_path("#{filename}.gif")))
			ext = 'gif'
		end
		"<img src=\"#{image_path(filename + '.' + ext)}\" alt=\"#{alt}\" #{other_properties.present? ? ' ' + other_properties : ''}/>".html_safe
	end

	def svg_sprite(filename, id, alt)
		if capable_of(:svg) && Rails.env != 'test'
			@svg_sprite_files ||= Hash.new
			output = ''
			id_ref = "##{id}"
			if get_browser_info[:agent] == 'ie' && get_browser_info[:version].to_i < 12
				# IE can't include a symbol from an external file, I'm assuming v12 will but we'll see
				if !@svg_sprite_files.has_key?(filename) || @svg_sprite_files[filename].blank?
					# include it if it hasn't already been done so that we can reference it
					svg_data = File.read(File.join(Rails.public_path, ActionController::Base.helpers.asset_path("#{filename}.svg")))
					output += svg_data.gsub('<svg', '<svg hidden')
					@svg_sprite_files[filename] = true
				end
			else
				# otherwise append the filename, stip off the domain to avoid x-origin errors in chrome
				id_ref = image_path(filename + '.svg').gsub(/^https?:\/\/.*?\//, '/') + id_ref
			end
			output += '<svg class="sprite ' + filename + ' ' + id + '"><use xlink:href="' + id_ref + '" /></svg>'
			return output.html_safe
		end
		return File.exists?(File.join(Rails.public_path, ActionController::Base.helpers.asset_path("#{id}.png"))) ? 
			"<img src=\"#{image_path(id + '.png')}\" class=\"sprite #{filename} #{id}\"/>".html_safe :
			"<div class=\"sprite #{filename} #{id}\"></div>".html_safe
	end
end
