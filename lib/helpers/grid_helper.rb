require "helpers/compatibility_helper"

module BuoyGridHelper
	include BuoyCompatibilityHelper

	def row(options = {}, &block)
		@@row_depth ||= 0
		@@row_depth += 1
		content = ''
		options = {:class => 'row'}
		@@columns ||= {}
		@@columns[@@row_depth] = {:depth => 0, :width => 0}
		@@can_make_columns = true
		if block_given?
			content = capture(&block)

			if !capable_of(:css_sel3)
				content = content.gsub(/(<div class=\"columns[^\"]*)\s+\*\*buoy-row\-#{@@row_depth}\*\*nth\-child\-#{@@columns[@@row_depth][:width]}([\s\"])/, '\1 last-child\2').html_safe
				content = content.gsub(/(<div class=\"columns[^\"]*)\s+\*\*buoy-row\-#{@@row_depth}\*\*nth\-child\-(\d+)/, '\1').html_safe
			end
		end
		@@row_depth -= 1
		content_tag(:div, content, options)
	end

	def column(options = {}, attributes = {}, &block)
		# first check to make sure our settings file looks right
		if (banned = buoy_settings['breakpoints'].keys & ['default', 'push']).present?
			raise "Breakpoint name \"#{banned.first}\" is not a valid breakpoint name"
		end

		@@row_depth ||= 0
		if @@row_depth < 1 || !@@can_make_columns
			raise "Columns must be contained in a row"
		end

		@@can_make_columns = false
		
		@@columns[@@row_depth][:width] += 1

		content = ''
		attributes[:class] ||= []
		attributes[:class] << 'columns'

		options.each { | size, width |
			size = _to_string(size)
			if /^(push|pull)$/.match(size)
				if width.is_a?(Numeric)
					width = {:default => width}
				end
				width.each { | s, w |
					_check_column_width(w, true)

					sz = ''
					s = _to_string(s)
					if s != 'default'
						_check_breakpoint(s)
						sz = "#{s}-"
					end
					attributes[:class] << "#{sz}#{size}-#{w.to_s}"
				}
			else
				_check_breakpoint(size)
				_check_column_width(width)

				attributes[:class] << "#{size.to_s}-#{width.to_s}"
			end
		}

		if attributes[:end]
			attributes[:class] << 'end'
		end
		
		if !capable_of(:css_sel3)
			if @@columns[@@row_depth][:width] == 1
				attributes[:class] << 'first-child'
			end

			attributes[:class] << "**buoy-row-#{@@row_depth}**nth-child-#{@@columns[@@row_depth][:width].to_s}"
		end

		if block_given?
			content = capture(&block)
		end

		@@can_make_columns = true
		
		content_tag(:div, content, attributes)
	end

	private
		def _to_string(s)
			if s.is_a? Symbol
				s = s.to_s.gsub('_', '-')
			end
			s
		end

		def _check_breakpoint(b)
			size = _to_string(b)
			if !buoy_settings['breakpoints'].has_key?(size.to_s)
				raise "Use of undeclared breakpoint \"#{size}\""
			end
			if (buoy_settings['breakpoints'][size.to_s]['grid'] || 'n') == 'n'
				raise "Breakpoint \"#{size}\" is not a valid grid breakpoint"
			end
		end

		def _check_column_width(w, is_push_pull = false)
			min = 1
			max = buoy_settings['total-columns']

			if is_push_pull
				min -= 1
				max -= 1
			end

			if w.to_i < min || w.to_i > max
				raise "Invalid #{is_push_pull ? 'push or pull size' : 'column width'} \"#{size}\""
			end
		end
end
