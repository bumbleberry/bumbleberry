require "helpers/cache_helper"

module BuoySettingsHelper
	include BuoyCacheHelper

	def buoy_settings
		return cache_retrieve(:settings) || cache(:settings, Buoy::settings)
	end

	def get_caniuse_data()
		return cache_retrieve(:caniuse_data) || cache(:caniuse_data, Buoy::get_caniuse_data)
	end

	def get_browser_info()
		return cache_retrieve(:browser_info) || cache(:browser_info, Buoy::detect(request.user_agent, get_caniuse_data))
	end
end
