require "helpers/compatibility_helper"

module BumbleberryGridHelper
	include BumbleberryCompatibilityHelper

	def row(options = {}, &block)
		return unless block_given?

		@@row_depth ||= 0
		@@row_depth += 1
		content = ''
		options = {:class => 'row'}
		@@columns ||= {}
		@@columns[@@row_depth] = {:depth => 0, :width => 0}
		@@can_make_columns = true

		tag = :div

		content = capture(&block)

		if !capable_of(:css3_boxsizing)
			# hey, if we can't do box sizing, we're on a really old browser
			#  so do it like they used to
			tag = :table
			options[:border] = 0
			content = "<tr>#{'<th class="column-set"></th>' * 12}</tr><tr>#{content}</tr>".html_safe
		elsif !capable_of(:css_sel3)
			content = content.gsub(/(<div class=\"columns[^\"]*)\s+\*\*bumbleberry-row\-#{@@row_depth}\*\*nth\-child\-#{@@columns[@@row_depth][:width]}([\s\"])/, '\1 last-child\2').html_safe
			content = content.gsub(/(<div class=\"columns[^\"]*)\s+\*\*bumbleberry-row\-#{@@row_depth}\*\*nth\-child\-(\d+)/, '\1').html_safe
		end

		@@row_depth -= 1
		content_tag(tag, content, options)
	end

	def column(options = {}, attributes = {}, &block)
		# first check to make sure our settings file looks right
		if (banned = bumbleberry_settings['breakpoints'].keys & ['default', 'push']).present?
			raise "Breakpoint name \"#{banned.first}\" is not a valid breakpoint name"
		end

		@@row_depth ||= 0
		if @@row_depth < 1# || !@@can_make_columns
			raise "Columns must be contained in a row"
		end

		@@can_make_columns = false
		
		@@columns[@@row_depth][:width] += 1

		content = ''

		if block_given?
			content = capture(&block)
		end

		attributes[:class] ||= []
		attributes[:class] = [attributes[:class]] if attributes[:class].is_a?(String)
		attributes[:class] << 'columns'

		render_as_table = !capable_of(:css3_boxsizing)
		tag = render_as_table ? :td : :div

		options.each { | size, width |
			size = _to_string(size)
			if /^(push|pull)$/.match(size)
				if !render_as_table
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
				end
			else
				_check_breakpoint(size)
				_check_column_width(width)

				if render_as_table
					max_width ||= 0
					# figure out if it should be displayed
					if size_is_unresponsive(size) && max_width <= upper_bound(size)
						attributes[:colspan] = width
						max_width = upper_bound(size)
					end
				else
					attributes[:class] << "#{size.to_s}-#{width.to_s}"
				end
			end
		}

		max_width ||= true
		if !max_width
			# if it isn't going to be displayed, don't display it
			return ''
		end

		if render_as_table
			attributes[:colspan] ||= bumbleberry_settings['total-columns']
		end

		if attributes[:end]
			if render_as_table
				content += '</tr><tr>'.html_safe
			else
				attributes[:class] << 'end'
			end
		end
		
		if !render_as_table && !capable_of(:css_sel3)
			if @@columns[@@row_depth][:width] == 1
				attributes[:class] << 'first-child'
			end

			attributes[:class] << "**bumbleberry-row-#{@@row_depth}**nth-child-#{@@columns[@@row_depth][:width].to_s}"
		end

		@@can_make_columns = true
		
		content_tag(tag, content, attributes)
	end

	alias_method :columns, :column

	private
		def _to_string(s)
			if s.is_a? Symbol
				s = s.to_s.gsub('_', '-')
			end
			s
		end

		def _check_breakpoint(b)
			size = _to_string(b)
			if !bumbleberry_settings['breakpoints'].has_key?(size.to_s)
				raise "Use of undeclared breakpoint \"#{size}\""
			end
			if (bumbleberry_settings['breakpoints'][size.to_s]['grid'] || 'n') == 'n'
				raise "Breakpoint \"#{size}\" is not a valid grid breakpoint"
			end
		end

		def _check_column_width(w, is_push_pull = false)
			min = 1
			max = bumbleberry_settings['total-columns']

			if is_push_pull
				min -= 1
				max -= 1
			end

			if w.to_i < min || w.to_i > max
				raise "Invalid #{is_push_pull ? 'push or pull size' : 'column width'} \"#{size}\""
			end
		end

		def lower_bound(size)
			bumbleberry_settings['breakpoints'][size.to_s]['range'][0]
		end

		def upper_bound(size)
			bounds = bumbleberry_settings['breakpoints'][size.to_s]['range']
			bounds.length > 1 ? bounds[1] : 999999
		end

		def size_is_unresponsive(size)
			w = bumbleberry_settings['unresponsive-width']
			w >= lower_bound(size) && w <= upper_bound(size)
		end
end
