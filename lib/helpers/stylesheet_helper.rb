require "helpers/compatibility_helper"

module BumbleberryStylesheetHelper
	include BumbleberryCompatibilityHelper

	def get_stylesheet(path)
		return _profile("get_browser_info") do
			info = get_browser_info
			File.join(path.gsub(/^(.*)\.(s?css|sass)$/, '\1'), Bumbleberry::stylesheet_name(info[:agent], info[:version]))
		end
	end

	def inject_css!(filename = 'application')
		return _profile("inject_css! #{filename}") do
			@first_stylsheet_included ||= false
			filename = _profile("get_stylesheet #{filename}") { get_stylesheet(filename) }
			output = ''
			output += '<link href="' + (_profile("path_to_stylesheet #{filename}") { path_to_stylesheet filename }) + '" rel="stylesheet" media="all" type="text/css" />'

			unless @first_stylsheet_included
				js = _profile('html5shiv') { html5shiv }
				output += "<script>#{js}</script>" if js

				# load the font script if localStorage is available, don't do it in test though because it makes output unreadable
				settings = _profile('bumbleberry_settings') { bumbleberry_settings }
				if (settings['font-loading-method'] == 'deferred' && (_profile('bumbleberry_settings') { capable_of(:namevalue_storage) })) || settings['font-loading-method'] == 'http2'
					webfonts = _profile('get_stylesheet web-fonts') { get_stylesheet('web-fonts') }
					font_filename = _profile('path_to_stylesheet webfonts') { path_to_stylesheet(webfonts + '.css') }
					stylesheet = '<link href="' + (_profile('path_to_stylesheet webfonts') { path_to_stylesheet(font_filename) }) + '" rel="stylesheet" media="all" type="text/css" />';
					if settings['font-loading-method'] == 'http2'
						output += stylesheet
					else
						output +=
							'<script>' + (_profile('deferred_fonts_script') { Bumbleberry::deferred_fonts_script }).gsub('web-fonts.css', path_to_stylesheet(font_filename)) + '</script>' + "\n" + 
							'<noscript>' + stylesheet + '</noscript>' + "\n"
					end
				end
				
				@first_stylsheet_included = true
			end

			output.html_safe
		end
	end

end
