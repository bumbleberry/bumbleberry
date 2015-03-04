ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
#require 'factory_girl'

Capybara.configure do |c|
  c.run_server = true
  c.javascript_driver = :poltergeist
  c.default_driver = :poltergeist
end

RSpec.configure do |config|
  config.render_views
end

#DatabaseCleaner.strategy = :truncation

feature 'Home page' do
  before(:each) do
    #DatabaseCleaner.clean
  end

  scenario 'test' do
    visit '/'
  end

end
