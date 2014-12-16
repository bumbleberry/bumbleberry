require "buoy/version"
require "buoy/engine" if defined?(::Rails)
require "buoy/buoy"
require "useragent"
require "fileutils"
require "yaml"
require "open-uri"
require "json"
require "action_view"

require "helpers/grid_helper"
require "helpers/multimedia_helper"
require "helpers/stylesheet_helper"

module BuoyHelper
	include BuoyGridHelper
	include BuoyMultimediaHelper
	include BuoyStylesheetHelper
end

ActionView::Base.send :include, BuoyHelper
