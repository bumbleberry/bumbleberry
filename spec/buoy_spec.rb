require "spec_helper"
require "yaml"

describe "Detect works as expected" do
	it 'Returns the correct stylesheet' do
		YAML.load_file(File.join(File.expand_path('../..', __FILE__), '/spec/useragents.yml')).each { | agent |
			stylesheet = Buoy::get_stylesheet('assets/application.scss', agent['user_agent'])
			expected = "assets/application/#{agent['agent']}-#{agent['version']}"
			expect(stylesheet).to eq(expected), "\n\nExpected stylesheet to be #{expected} but was #{stylesheet}:\n\t#{agent['user_agent']}\n\n"
		}
	end
end
