require "buoy/buoy"
#require "buoy"

module BuoyCacheHelper
	def cache_retrieve(key)
		session[:buoy] ||= Hash.new
		# we save items in the cache under the user agent otherwise if the user
		# switches the user agent, we will not know to look up the data again
		session[:buoy][request.user_agent] ||= Hash.new
		session[:buoy][request.user_agent][key]
	end

	def cache(key, data)
		session[:buoy] ||= Hash.new
		session[:buoy][request.user_agent] ||= Hash.new
		return session[:buoy][request.user_agent][key] || (session[:buoy][request.user_agent][key] = data)
	end
end
