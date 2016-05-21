require "helpers/settings_helper"

module BumbleberryCompatibilityHelper
	include BumbleberrySettingsHelper

	def get_capability(capability)
		return _profile("get_capability #{capability}") do
			info = get_browser_info
			caniuse = get_caniuse_data
			caniuse['data'][capability.to_s.gsub('_', '-')]['stats'][info[:agent]][info[:version]]
		end
	end

	def capable_of(capability)
		capable = get_capability(capability)
		return !!(/[ay]x?/.match(capable))
	end

	def html5shiv
		unless capable_of(:html5semantic)
			js = Array.new
			js << 'var d=document'
			html5elements = [:article, :aside, :details, :figcaption, :figure, :footer, :header, :main, :mark, :nav, :section, :summary, :time]
			html5elements.each do |element|
				js << "d.createElement('#{element.to_s}')"
			end
			js.join(';')
		end
	end

	def browsers
		{'chrome' => 'Chrome', 'ie' => 'Internet Explorer'}
	end
end
