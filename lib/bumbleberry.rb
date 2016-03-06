require "bumbleberry/version"
require "bumbleberry/engine" if defined?(::Rails)
require "bumbleberry/bumbleberry"
#require "fileutils"
#require "yaml"
#require "open-uri"
#require "json"
require "action_view"

require "helpers/grid_helper"
require "helpers/multimedia_helper"
require "helpers/stylesheet_helper"
require "helpers/sass_extensions"

module BumbleberryHelper
	include BumbleberryGridHelper
	include BumbleberryMultimediaHelper
	include BumbleberryStylesheetHelper
end

ActionView::Base.send :include, BumbleberryHelper
