require "helpers/compatibility_helper"

module BuoyStylesheetHelper
	include BuoyCompatibilityHelper

	def get_stylesheet(path)
		info = get_browser_info
		File.join(path.gsub(/^(.*)\.(s?css|sass)$/, '\1'), Buoy::stylesheet_name(info[:agent], info[:version]))
	end

	def inject_css!(filename = 'application')
		filename = get_stylesheet(filename)
		output = ''
		if buoy_settings['font-loading-method'] == 'deferred' && capable_of(:namevalue_storage)
			font_filename = path_to_stylesheet(get_stylesheet('web-fonts') + '.css')
			output +=
				'<script>' + (Buoy::deferred_fonts_script).gsub('web-fonts.css', path_to_stylesheet(font_filename)) + '</script>' + "\n" + 
				'<noscript><link href="' + path_to_stylesheet(font_filename) + '" rel="stylesheet" media="all" type="text/css" /></noscript>' + "\n"
		end
		output += '<link href="' + (path_to_stylesheet filename) + '" rel="stylesheet" media="all" type="text/css" />'
		output.html_safe
	end

end
