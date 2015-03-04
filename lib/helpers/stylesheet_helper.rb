require "helpers/compatibility_helper"

module BumbleberryStylesheetHelper
	include BumbleberryCompatibilityHelper

	def get_stylesheet(path)
		info = get_browser_info
		File.join(path.gsub(/^(.*)\.(s?css|sass)$/, '\1'), Bumbleberry::stylesheet_name(info[:agent], info[:version]))
	end

	def inject_css!(filename = 'application')
		@first_stylsheet ||= true
		filename = get_stylesheet(filename)
		output = ''
		if bumbleberry_settings['font-loading-method'] == 'deferred' && capable_of(:namevalue_storage)
			font_filename = path_to_stylesheet(get_stylesheet('web-fonts') + '.css')
			output +=
				'<script>' + (Bumbleberry::deferred_fonts_script).gsub('web-fonts.css', path_to_stylesheet(font_filename)) + '</script>' + "\n" + 
				'<noscript><link href="' + path_to_stylesheet(font_filename) + '" rel="stylesheet" media="all" type="text/css" /></noscript>' + "\n"
		end
		output += '<link href="' + (path_to_stylesheet filename) + '" rel="stylesheet" media="all" type="text/css" />'
		if @first_stylsheet
			js = html5shiv
			output += "<script>#{js}</script>" if js
		end
		@first_stylsheet = false
		output.html_safe
	end

end
