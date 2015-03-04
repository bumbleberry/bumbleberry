require "helpers/cache_helper"

module BumbleberrySettingsHelper
	include BumbleberryCacheHelper

	def bumbleberry_settings
		return cache_retrieve(:settings) || cache(:settings, Bumbleberry::settings)
	end

	def get_caniuse_data()
		return cache_retrieve(:caniuse_data) || cache(:caniuse_data, Bumbleberry::get_caniuse_data)
	end

	def get_browser_info()
		return cache_retrieve(:browser_info) || cache(:browser_info, Bumbleberry::detect(request.user_agent, get_caniuse_data))
	end
end
