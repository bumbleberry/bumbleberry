require "bumbleberry/bumbleberry"
#require "bumbleberry"

module BumbleberryCacheHelper
	def cache_retrieve(key)
		session[:bumbleberry] ||= Hash.new
		# we save items in the cache under the user agent otherwise if the user
		# switches the user agent, we will not know to look up the data again
		session[:bumbleberry][request.user_agent] ||= Hash.new
		session[:bumbleberry][request.user_agent][key]
	end

	def cache(key, data)
		session[:bumbleberry] ||= Hash.new
		session[:bumbleberry][request.user_agent] ||= Hash.new
		return session[:bumbleberry][request.user_agent][key] || (session[:bumbleberry][request.user_agent][key] = data)
	end
end
