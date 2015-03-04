require 'net/http'

module Bumbleberry

	def self.get_caniuse_data
		datafile = File.join(File.expand_path('../..', __FILE__), 'caniuse.json')
		if !File.exist?(datafile) || File.mtime(datafile) < (Time.now - 604800) # file doesnt exist or is more than a week old
			json = Net::HTTP.get('caniuse.com', '/jsonp.php').gsub(/^\s*\(\s*(.*)\s*\)\s*$/, '\1')
			File.open(datafile, 'w') { |f| f.write(json) }
		end
		JSON.parse(File.read(datafile))
	end

	def self.webkit_convert(webkit_version, browser = 'safari')
		last_match = 0
		YAML.load_file(File.join(File.expand_path('../..', __FILE__), 'webkit-map.yml')).each_pair { | wk_ver, data |
			if wk_ver > webkit_version
				return last_match
			end
			last_match = data[browser]
		}
		return last_match
	end
	
	def self.detect!(user_agent)
		self.detect(user_agent, self.get_caniuse_data)
	end

	def self.detect(user_agent, caniuse_data = nil)
		caniuse = caniuse_data# || self.get_caniuse_data

		info = {:agent => nil, :version => nil}

		if (match = /UC(\s?Browser|WEB)\/?(\d+)?(\.\d+)?/.match(user_agent))
			info[:agent] = 'and_uc'
			info[:version] = self.match_version("#{match[2]}#{match[3]}".to_f, caniuse['agents'][info[:agent]]['versions'])
		elsif /(AppleWebKit)?.*(?<!like\s)(iPhone|iPad).*(AppleWebKit)?/i.match(user_agent)
			info[:agent] = 'ios_saf'
			if (match = /Opera\s*Mini\/(\d+)(\.\d+)?/i.match(user_agent))
				info[:agent] = 'op_mini'
				info[:version] = self.match_version("#{match[1]}#{match[2]}".to_f, caniuse['agents'][info[:agent]]['versions'])
			elsif !(/(Chrome|Opera)/i.match(user_agent)) && (match = /Version\/(\d+)(\.\d+)?/.match(user_agent))
				info[:version] = self.match_version("#{match[1]}#{match[2]}".to_f, caniuse['agents'][info[:agent]]['versions'])
			else
				info[:version] = self.match_version(self.webkit_convert(user_agent.gsub(/^.*AppleWebKit\/(\d+)(\.\d+)?.*$/, '\1\2').to_f), caniuse['agents'][info[:agent]]['versions'])
			end
		elsif (match = /Opera\/.*Version\/(\d+)(\.\d+)?/.match(user_agent)) ||
		  (match = /Opera[\s\/](\d+)(\.\d+)?/.match(user_agent)) ||
		  (match = /Opera/.match(user_agent))
			info[:agent] = (/Opera\s*Mini/.match(user_agent) ? 'op_mini' : (/Opera\s*Mobi/.match(user_agent) ? 'op_mob' : 'opera'))
			info[:version] = self.match_version(match[1] ? "#{match[1]}#{match[2]}".to_f : 0, caniuse['agents'][info[:agent]]['versions'])
		elsif (match = /IEMobile[\/\s](\d+)(\.\d+)?/.match(user_agent))
			info[:agent] = 'ie_mob'
			info[:version] = self.match_version("#{match[1]}#{match[2]}".to_f, caniuse['agents'][info[:agent]]['versions'])
		elsif (match = /MSIE ([\w\.]+)/.match(user_agent)) || (match = /Internet Explorer (\d+)/.match(user_agent)) || (match = /rv:([\d\.]+).*like\s*Gecko\s*$/.match(user_agent)) || (match = /Edge\/([\w\.]+)/.match(user_agent))
			info[:agent] = 'ie'
			version = match[1]
			if /^\d+(\.\d+)?(b\d?)?$/.match(version)
				version = version.to_f
			end
			if version == 7 && !(/chromeframe\/8/.match(user_agent)) && /Trident\/5/.match(user_agent)
				info[:version] = /WOW64.*SLCC1/.match(user_agent) ? '8' : '9'
			elsif version == 7 && /Trident\/[45]/.match(user_agent)
				info[:version] = '8'
			elsif version == 6 && /MSIE 5\.5/.match(user_agent)
				info[:version] = '5.5'
			else
				info[:version] = self.match_version(version, caniuse['agents'][info[:agent]]['versions'])
			end
		elsif (match = /Firefox.*?(\d+)(\.\d+)/i.match(user_agent)) || (match = /Firefox$/.match(user_agent))
			if (/(Android|iPhone|iPad)/.match(user_agent)) && match[1].to_f > 20 # FF for IOS doesn't exist yet but if it does, we'll treat it as android until we update the code
				info[:agent] = 'and_ff'
			else
				info[:agent] = 'firefox'
			end
			info[:version] = self.match_version(match[1] ? "#{match[1]}#{match[2]}".to_f : 1, caniuse['agents'][info[:agent]]['versions'])
		elsif (match = /Chrome\/((\d+)(\.\d+)?)?/.match(user_agent))
			if (/(iPhone|iPad)/.match(user_agent))
				info[:agent] = 'and_chr'
			elsif (/(Android|iPhone|iPad)/.match(user_agent))
				info[:agent] = 'and_chr'
			else
				info[:agent] = 'chrome'
			end
			info[:version] = self.match_version(match[1].to_f, caniuse['agents'][info[:agent]]['versions'])
		elsif /(BlackBerry\s?\d{4}|BB\d\d;\s*(Kbd|Touch))/.match(user_agent)
			info[:agent] = 'bb'
			match = /(Version\/|BB)(\d+)(\.\d+)?/.match(user_agent)
			info[:version] = self.match_version(match ? "#{match[2]}#{match[3]}".to_f : 0, caniuse['agents'][info[:agent]]['versions'])
		elsif (match = /Android\s*(\d+)(\.\d+)?/.match(user_agent))
			info[:agent] = 'android'
			info[:version] = self.match_version("#{match[1]}#{match[2]}".to_f, caniuse['agents'][info[:agent]]['versions'])
		elsif (match = /Version\/(\d+)(\.\d+)?(\.\d+)?(\w+)?(\sMobile\/\w+)?\s+Safari/.match(user_agent)) ||
		  (match = /Version\/(\d+)(\.\d+)?(\.\d+)?(\w+)?\siPhone/.match(user_agent)) ||
		  (match = /Macintosh; U; PPC Mac OS/.match(user_agent)) || (match = /Mobile Safari/.match(user_agent))
			info[:agent] = 'safari'
			info[:version] = self.match_version(match[1] ? "#{match[1]}#{match[2]}".to_f : 0, caniuse['agents'][info[:agent]]['versions'])
		elsif (match = /AppleWebKit\/(\d+)(\.\d+)?/.match(user_agent))
			info[:agent] = 'safari'
			info[:version] = self.match_version(self.webkit_convert("#{match[1]}#{match[2]}".to_f), caniuse['agents'][info[:agent]]['versions'])
		end

		if !info[:agent]
			info[:agent] = 'safari'
		end
		
		if !info[:version]
			info[:version] = self.match_version(0, caniuse['agents'][info[:agent]]['versions'])
		end

		return info
	end

	def self.match_version(version, all_versions)
		best_match = nil
		smallest = nil

		best_match_s = nil
		smallest_s = nil
		all_versions.each { | this_version |
			if this_version
				this_version_s = this_version

				if /^\d+(\.\d+)?(\-\d+(\.\d+))?$/.match(this_version)
					this_version = this_version.to_f
					if !smallest || smallest >= this_version
						smallest = this_version
						smallest_s = this_version_s
					end
				end

				if version.is_a?(String)
					if this_version.to_s == version
						return this_version_s
					end
				elsif this_version.is_a?(Float)
					if this_version == version
						return this_version_s
					end
					if version > this_version
						best_match = this_version
						best_match_s = this_version_s
					end
				end
			end
		}

		return best_match_s || smallest_s
	end
	
	def self.settings
		file = File.join(Dir.pwd, 'app', 'assets', 'stylesheets', 'bumbleberry-settings.json')
		if File.exist?(file)
			# we've already got it installed so return the data
			return JSON.parse(File.read(file))
		end

		# make sure we have the scss settings file
		scss_settings = File.join(Dir.pwd, 'app', 'assets', 'stylesheets', '_bumbleberry-settings.scss')
		if !File.exist?(scss_settings)
			File.open(scss_settings, 'w') { |f| f.write(File.read(File.join(File.expand_path('../../..', __FILE__), 'app/assets/stylesheets/_bumbleberry-settings.scss'))) }
		end

		# now copy over the default settings
		default_json = File.read(File.join(File.expand_path('../../..', __FILE__), 'app/assets/stylesheets/bumbleberry-settings.json'))
		File.open(file, 'w') { |f| f.write(default_json) }

		# and return it
		JSON.parse(default_json)
	end

	def self.update!
		settings = self.settings

		if settings['font-loading-method'] == 'deferred'
			settings['stylesheets'] << 'web-fonts'
		end

		caniuse = self.get_caniuse_data
		template = File.read(File.join(File.expand_path('../..', __FILE__), 'template.scss'))

		settings['stylesheets'].each { | path |
			if !(/^_.*/.match(path))
				caniuse['agents'].each_pair { | agent, agent_data |
					agent_data['versions'].each { | version |
						if (version)
							prefix = agent_data['prefix']
							if (agent_data.has_key?('prefix_exceptions') && agent_data['prefix_exceptions'].has_key?(version))
								prefix = agent_data['prefix_exceptions'][version]
							end
							filename = self.stylesheet_name(agent, version) + '.scss'

							css_compatibility = ''
							css_compatibility_indent = (/^(\s*)#{Regexp.quote(self.template_var('css_compatibility'))}/.match(template))[1]

							caniuse['data'].each_pair { | property, data |
								if css_compatibility.present?
									css_compatibility += ",\n#{css_compatibility_indent}"
								end
								css_compatibility += "\"#{property}\": #{data['stats'][agent][version].gsub(/[\s\#\d]/, '')}"
							}

							scss = template.
								gsub(self.template_var('browser'), agent).
								gsub(self.template_var('browser_prefix'), prefix).
								gsub(self.template_var('browser_version'), version).
								gsub(self.template_var('browser_type'), agent_data['type']).
								gsub(self.template_var('browser_abbr'), agent_data['abbr']).
								gsub(self.template_var('browser_name'), agent_data['browser']).
								gsub(self.template_var('browser_usage'), agent_data['usage_global'][version].round(2).to_s).
								gsub(self.template_var('css_compatibility'), css_compatibility).
								gsub(self.template_var('path'), path == 'web-fonts' ? path : "../#{path}").
								gsub(self.template_var('bumbleberry-no-markup'), path == 'web-fonts' ? "\n$bumbleberry-no-markup: true;" : '')

							file = File.join(Dir.pwd, 'app', 'assets', 'stylesheets', path.gsub(/(\.css)?(\.s[ac]ss)?/, ''))
							FileUtils.mkdir_p(file)

							File.open(File.join(file, filename), 'w') { |f| f.write(scss) }
						end
					}
				}
			end
		}
	end

	def self.template_var(var)
		"[%#{var}%]"
	end

	def self.stylesheet_name(agent, version)
		"#{agent}-#{version}"
	end

	def self.deferred_fonts_script
		File.read(File.join(File.expand_path('../..', __FILE__), 'deferred-font-loading.min.js'))
	end

	# a list of things that bumbleberry does
	def self.bumbleberry_functions
		{
			:svgs => {:name => 'Vector Graphics', :description => 'SVG graphics with fallbacks'},
			:web_fonts => {:name => 'Web Fonts', :description => 'Load only one font and caches if possible'},
			:grid => {:name => 'Grid Layout', :description => 'A grid layout with table fallback'}
		}
	end
end
