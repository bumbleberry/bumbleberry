require 'bundler/setup'
Bundler.setup

require 'buoy' # and any other gems you need

module BuoyHelperMock
	include BuoyHelper
	
	def cache_retrieve(key)
		nil
	end

	def cache(key, data)
		return data
	end

	def buoy_settings
		@@settings ||= {}
		@@settings
	end

	def clear_buoy_settings!
		@@settings = {}
	end

	def set_buoy_settings(settings)
		@@settings ||= {}
		@@settings.deep_merge!(settings)
	end

	def _init!
		@@row_depth = nil
		clear_buoy_settings!
	end
end

class RequestMock
	def initialize(user_agent)
		@user_agent = user_agent
	end

	def user_agent
		return @user_agent
	end
end

RSpec.configure do |config|
  config.include BuoyHelper

  def init(test_object = nil)
  	ActionView::Base.send :include, BuoyHelperMock
  	@test_object = test_object || ActionView::Base.new
  	@test_object._init!
  	set({
  		'breakpoints' => {
			'small'  => {'range' => [0], 'grid' => 'y'},
			'medium' => {'range' => [640], 'grid' => 'y'},
			'large'  => {'range' => [1024], 'grid' => 'y'}
		  },
		'total-columns' => 12,
		'font-loading-method' => 'deferred'
	  })
  	use(:chrome, 40)
  end

  def set(settings)
  	@test_object.set_buoy_settings(settings)
  end

  def use(browser, version)
  	user_agent = ''
  	if browser == :chrome
  		user_agent = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/#{version}.0.0.0 Safari/537.36"
	elsif browser == :ie
		if version == 11
			user_agent = "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; .NET4.0E; .NET4.0C; rv:11.0) like Gecko"
		elsif version == 7
			user_agent = "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)"
		else
			user_agent = "Mozilla/5.0 (compatible; MSIE #{version}.0; Windows NT 6.1; Trident/5.0)"
  		end
  	elsif :firefox
  		user_agent = "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/#{version}.0"
  	elsif :opera
  		user_agent = "Opera/9.80 (X11; Linux i686; Ubuntu/14.10) Presto/2.12.388 Version/#{version}.0"
  	elsif :safari
  		user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/#{version}.0.0 Safari/7046A194A"
  	elsif :android
  		user_agent = "Mozilla/5.0 (Linux; U; Android #{version}.0; en-us) AppleWebKit/999+ (KHTML, like Gecko) Safari/999.9"
  	end
	allow(@test_object).to receive(:request).and_return(RequestMock.new(user_agent))
  end

  def render(string)
  	ActionView::Template::Handlers::Erubis.new(string).evaluate(@test_object).gsub(/[\n\t]/, '').gsub(/>\s+</, '><')
  end

end
