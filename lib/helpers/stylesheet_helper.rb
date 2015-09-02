require "helpers/compatibility_helper"

module BumbleberryStylesheetHelper
	include BumbleberryCompatibilityHelper

	def get_stylesheet(path)
		info = get_browser_info
		File.join(path.gsub(/^(.*)\.(s?css|sass)$/, '\1'), Bumbleberry::stylesheet_name(info[:agent], info[:version]))
	end

	def inject_css!(filename = 'application')
		@first_stylsheet_included ||= false
		filename = get_stylesheet(filename)
		output = ''
		output += '<link href="' + (path_to_stylesheet filename) + '" rel="stylesheet" media="all" type="text/css" />'
		if !@first_stylsheet_included
			js = html5shiv
			output += "<script>#{js}</script>" if js

			# load the font script if localStorage is available, don't do it in test though because it makes output unreadable
			if bumbleberry_settings['font-loading-method'] == 'deferred' && capable_of(:namevalue_storage)
				font_filename = path_to_stylesheet(get_stylesheet('web-fonts') + '.css')
				stylesheet = '<link href="' + path_to_stylesheet(font_filename) + '" rel="stylesheet" media="all" type="text/css" />';
				if Rails.env == 'test'
					output += stylesheet
				else
					output +=
						'<script>' + (Bumbleberry::deferred_fonts_script).gsub('web-fonts.css', path_to_stylesheet(font_filename)) + '</script>' + "\n" + 
						'<noscript>' + stylesheet + '</noscript>' + "\n"
				end
			end
			
			@first_stylsheet_included = true
		end
		output.html_safe
	end

end
