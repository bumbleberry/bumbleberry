require "helpers/settings_helper"

module BuoyCompatibilityHelper
	include BuoySettingsHelper

	def get_capability(capability)
		info = get_browser_info
		caniuse = get_caniuse_data
		return caniuse['data'][capability.to_s.gsub('_', '-')]['stats'][info[:agent]][info[:version]]
	end

	def capable_of(capability)
		capable = get_capability(capability)
		return !!(/yx?/.match(capable))
	end
end
