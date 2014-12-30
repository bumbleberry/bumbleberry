require "spec_helper"
require "yaml"
require "buoy"

describe BuoyHelper, :type => :helper do

	before(:each) do
		init
	end

	describe 'row' do

		it 'should create a div with a row class' do
			use(:chrome, 39)

			expected = '<div class="row"></div>'
			
			template =
			<<-TEMPLATE
			<%= row %>
			TEMPLATE

			expected = '<div class="row"></div>'
			actual = render(template)

			expect(actual).to eq(expected)
		end
	
		it 'should create a div with a row class and a column' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns medium-8"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 8 %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should create a row containing multiple columns' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns medium-4"></div><div class="columns medium-8"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 4 %>
			  <%= column :medium => 8 %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should mark the first and last columns in ie8' do
			use(:ie, 8)

			expected = '<div class="row"><div class="columns medium-4 first-child"></div><div class="columns medium-8 last-child"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 4 %>
			  <%= column :medium => 8 %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should raise an error if an invalid screen size is used' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :med => 7 %>
			  <%= column :med => 6 %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should add push class' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns medium-6 push-3"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 6, :push => 3 %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should add push class for breakpoints' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns medium-6 large-push-3"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 6, :push => {:large => 3} %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should add push class for breakpoints and all' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns medium-6 push-2 large-push-3"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 6, :push => {:default => 2, :large => 3} %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should identify deault as invalid breakpoint name' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => 6 %>
			<% end %>
			TEMPLATE

			set({'breakpoints' => {'default' => {'range' => [0]}}})

			expect { render(template) }.to raise_error('Breakpoint name "default" is not a valid breakpoint name')
		end

		it 'should identify push as invalid breakpoint name' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :default => 6 %>
			<% end %>
			TEMPLATE

			set({'breakpoints' => {'push' => {'range' => [0]}}})

			expect { render(template) }.to raise_error('Breakpoint name "push" is not a valid breakpoint name')
		end

		it 'should raise an error if an invalid screen size is used' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 7, :push => {:med => 2} %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should convert underscores to hyphens' do
			use(:chrome, 39)

			set({'breakpoints' => {'x-large' => {'range' => [0], 'grid' => 'y'}}})

			expected = '<div class="row"><div class="columns x-large-5"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :x_large => 5 %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should accept strings' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns small-5"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column 'small' => 5 %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should raise an error if push breakpoint has not been defined for grids' do
			use(:chrome, 39)

			set({'breakpoints' => {'x-large' => {'range' => [0], 'grid' => 'n'}}})

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :x_large => 5 %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should raise an error if push breakpoint has not been defined for grids' do
			use(:chrome, 39)

			set({'breakpoints' => {'x-large' => {'range' => [0], 'grid' => 'n'}}})

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :medium => 7, :push => {:x-large => 2} %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should render column block' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns small-5"><p>Hi there</p></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column 'small' => 5 do %>
			    <p>Hi there</p>
			  <% end %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should accept a string as a width' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns small-12"></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column 'small' => '12' %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end

		it 'should raise an error if width is less than 1' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => 0 %>
			<% end %>
			TEMPLATE
			
			expect { render(template) }.to raise_error
		end

		it 'should raise an error if width is less than 0' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => -5 %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should raise an error if width is more than 12' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => 13 %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should not except nil as width' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => nil %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should not except empty string as width' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => '' %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should not except random string as width' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => 'A' %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should not accept columns outside of rows' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= column :small => 6 do %>
			  <p>Hello world<p>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should not accept columns inside columns outside of rows' do
			use(:chrome, 39)

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => 6 do %>
			    <%= column :small => 12 do %>
			      <p>Hello world<p>
			    <% end %>
			  <% end %>
			<% end %>
			TEMPLATE

			expect { render(template) }.to raise_error
		end

		it 'should accept columns in rows in columns in rows' do
			use(:chrome, 39)

			expected = '<div class="row"><div class="columns small-6"><div class="row"><div class="columns small-12"><p>Hello world!</p></div></div></div></div>'

			template =
			<<-TEMPLATE
			<%= row do %>
			  <%= column :small => 6 do %>
			    <%= row do %>
			      <%= column :small => 12 do %>
			        <p>Hello world!</p>
			      <% end %>
			    <% end %>
			  <% end %>
			<% end %>
			TEMPLATE

			actual = render(template)

			expect(actual).to eq(expected)
		end
	end
end
