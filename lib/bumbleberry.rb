require "bumbleberry/version"
require "bumbleberry/engine" if defined?(::Rails)
require "bumbleberry/bumbleberry"
require "action_view"

require "helpers/grid_helper"
require "helpers/multimedia_helper"
require "helpers/stylesheet_helper"
require "helpers/sass_extensions"

module BumbleberryHelper
	def _profile(name, &block)
		if defined? Rack::MiniProfiler
			return Rack::MiniProfiler.step(name, &block)
		end
		yield
	end

	include BumbleberryGridHelper
	include BumbleberryMultimediaHelper
	include BumbleberryStylesheetHelper
end

ActionView::Base.send :include, BumbleberryHelper
