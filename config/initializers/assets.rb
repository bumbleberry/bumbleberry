require 'bumbleberry/bumbleberry'

basedir = File.join(Dir.pwd, 'app', 'assets', 'stylesheets')

# precompile all scss files for each bumbleberry file
Rails.application.config.assets.precompile += [File.join('web-fonts', "*.css")]
Bumbleberry::settings['stylesheets'].each { | path |
	#Rails.application.config.assets.precompile += [File.join(basedir, path, "*.css")]
	Rails.application.config.assets.precompile += [File.join(path, "*.css")]
}
