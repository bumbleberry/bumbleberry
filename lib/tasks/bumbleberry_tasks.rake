# desc "Explaining what the task does"

namespace :bumbleberry do
  task :update do
  	require 'bumbleberry'
  	Bumbleberry::update!
  end
end
