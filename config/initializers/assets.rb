require 'bumbleberry/bumbleberry'

basedir = File.join(Dir.pwd, 'app', 'assets', 'stylesheets')

# precompile all scss files for each bumbleberry file
precompile = Array.new
(Bumbleberry::settings['precompile'][Rails.env] || {}).each do |k,v|
	v.each do |version|
		precompile << "#{k}-#{version}"
	end
end

precompile << '*' if precompile.empty?

precompile.each do |p|
	Rails.application.config.assets.precompile << File.join('web-fonts', "#{p}.css")
end

Bumbleberry::settings['stylesheets'].each do | path |
	precompile.each do |p|
		Rails.application.config.assets.precompile << File.join(path, "#{p}.css")
	end
end
