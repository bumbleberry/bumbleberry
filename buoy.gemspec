# -*- encoding: utf-8 -*-
require File.expand_path('../lib/buoy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "buoy"
  gem.authors       = ["Godwin"]
  gem.email         = ["goodgodwin@hotmail.com"]
  gem.description   = "Functions and CSS built to ease cross browser compatibility, mobile design, UI components, etc."
  gem.summary       = "UI helper orgininally designed for bikecollectives."
  gem.homepage      = "http://bikecollectives.org"
  gem.licenses      = ["MIT"]

  gem.files         = Dir["{app,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  gem.require_paths = ["lib"]
  gem.version       = Buoy::Rails::VERSION

  gem.add_dependency "railties", ">= 3.2", "< 5.0"
  gem.add_dependency "sass-rails"
  gem.add_dependency "sass-json-vars"
  gem.add_dependency "useragent"

  gem.add_development_dependency "haml-rails"
  gem.add_development_dependency "rspec"
end
