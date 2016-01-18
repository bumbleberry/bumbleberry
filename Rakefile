require "rake/testtask"
require "bundler/gem_tasks"

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Rake::TestTask.new do |t|
  #t.libs << 'test'
end

#task :default => :test
#
#require 'rdoc/task'
#
#RDoc::Task.new(:rdoc) do |rdoc|
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title    = 'Bumbleberry'
#  rdoc.options << '--line-numbers'
#  rdoc.rdoc_files.include('README.rdoc')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end




#Bundler::GemHelper.install_tasks
#
#require 'rake/testtask'
#
#Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib'
#  t.libs << 'test'
#  t.pattern = 'test/**/*_test.rb'
#  t.verbose = false
#end
#
#
#task default: :test

#namespace :bumbleberry do
#  require File.expand_path('../lib/bumbleberry', __FILE__)
#
#  task :test do
#    Bumbleberry::test!
#  end
#end

task :build do
  #system "gem install useragent"
end
