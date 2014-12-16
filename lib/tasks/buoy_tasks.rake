# desc "Explaining what the task does"

namespace :buoy do
  task :update do
  	require 'buoy'
  	Buoy::update!
  end
end
