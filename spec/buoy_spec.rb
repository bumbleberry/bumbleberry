require "spec_helper"
require "yaml"
require "buoy"

describe BuoyHelper, :type => :helper do

	describe "get_stylesheet" do
		YAML.load_file(File.join(File.expand_path('../..', __FILE__), '/spec/useragents.yml')).each { | agent |
			it ('returns the correct stylesheet for ' + agent['user_agent']) do
				init
				set_agent(agent['user_agent'])
				stylesheet = @test_object.get_stylesheet('assets/application.scss')
				expected = "assets/application/#{agent['agent']}-#{agent['version']}"
				expect(stylesheet).to eq(expected), "\n\nExpected stylesheet to be #{expected} but was #{stylesheet}:\n\t#{agent['user_agent']}\n\n"
			end
		}
	end
end
