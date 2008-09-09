module Searchgasm
  module Helpers
    module ControlTypes
      module Links
        # Creates a group of links that order the data by a column or columns. All that this does is loop through the :choices option and call order_by_link and then glue it all together.
        #
        # === Examples
        #
        #   order_by_links
        #   order_by_links(:choices => [:name, {:orders => {:line_items => :total}}, :email])
        #
        # === Options
        #
        # Please look at order_by_link. All options there are applicable here and are passed onto each option.
        #
        # * <tt>:choices</tt> -- default: the models column names, the choices to loop through when calling order_by_link
        def order_by_links(options = {})
          add_order_by_links_defaults!(options)
          link_options = options.dup
          link_options.delete(:choices)
          html = ""
          options[:choices].each { |choice| html += order_by_link(choice, link_options.dup) }
          html
        end
        
        # Creates a group of links that ascend or descend the data. All that this does is loop through the :choices option and call order_as_link and then glue it all together.
        #
        # === Examples
        #
        #   order_as_links
        #   order_as_links(:choices => [:ascending, :descending])
        #
        # === Options
        #
        # Please look at order_as_link. All options there are applicable here and are passed onto each option.
        #
        # * <tt>:choices</tt> -- default: ["asc", "desc"], the choices to loop through when calling order_as_link
        def order_as_links(options = {})
          add_order_as_links_defaults!(options)
          link_options = options.dup
          link_options.delete(:choices)
          html = ""
          options[:choices].each { |choice| html += order_as_link(choice, link_options.dup) }
          html
        end
        
        # Creates a group of links that limit how many items are on each page. All that this does is loop through the :choices option and call per_page_link and then glue it all together.
        #
        # === Examples
        #
        #   per_page_links
        #   per_page_links(:choices => [25, 50, nil])
        #
        # === Options
        #
        # Please look at per_page_link. All options there are applicable here and are passed onto each option.
        #
        # * <tt>:choices</tt> -- default: [10, 25, 50, 100, 150, 200, nil], the choices to loop through when calling per_page_link.
        def per_page_links(options = {})
          add_per_page_links_defaults!(options)
          link_options = options.dup
          link_options.delete(:choices)
          html = ""
          options[:choices].each { |choice| html += per_page_link(choice, link_options.dup) }
          html
        end
        
        # Creates a group of links that paginate through the data. Kind of like a flickr page navigation. This one has some nifty options.
        #
        # === Examples
        #
        #   page_links
        #   page_links(:choices => [25, 50, nil])
        #
        # === Options
        #
        # Please look at per_page_link. All options there are applicable here and are passed onto each option.
        #
        # * <tt>:spread</tt> -- default: 3, how many choices available on each side of the current page
        # * <tt>:prev</tt> -- default: <, set to nil to omit. This is an extra link on the left side of the page links that will go to the previous page
        # * <tt>:next</tt> -- default: >, set to nil to omit. This is an extra link on the right side of the page links that will go to the next page
        # * <tt>:first</tt> -- default: <<, set to nil to omit. This is an extra link on thefar left side of the page links that will go to the first page
        # * <tt>:last</tt> -- default: >>, set to nil to omit. This is an extra link on the far right side of the page links that will go to the last page
        def page_links(options = {})
          add_page_links_defaults!(options)
          
          current_page = options[:search_obj].page
          page_start = 0
          page_end = 0
          if !options[:spread].blank?
            page_start = current_page - options[:spread]
            page_start = options[:choices].first unless options[:choices].include?(page_start)
            page_end = current_page + options[:spread]
            page_end = options[:choices].last unless options[:choices].include?(page_end)
          else
            page_start = options[:choices].first
            page_end = options[:choices].last
          end
          
          
          link_options = options.dup
          [:choices, :spread, :prev, :next, :first, :last].each { |option| link_options.delete(option) }
          html = ""
          (page_start..page_end).each { |choice| html += page_link(choice, link_options.dup) }
          html
        end
        
        private
          def add_order_by_links_defaults!(options)
            add_searchgasm_helper_defaults!(:order_by, options)
            options[:choices] ||= options[:search_obj].klass.column_names.map(&:humanize)
            options
          end
          
          def add_order_as_links_defaults!(options)
            add_searchgasm_helper_defaults!(:order_as, options)
            options[:choices] = [:asc, :desc]
            options
          end
          
          def add_per_page_links_defaults!(options)
            add_searchgasm_helper_defaults!(:per_page, options)
            options[:choices] ||= Config.per_page_choices.dup
            if !options[:search_obj].per_page.blank? && !options[:choices].include?(options[:search_obj].per_page)
              options[:choices] << options[:search_obj].per_page
              has_nil = options[:choices].include?(nil)
              options[:choices].compact!
              options[:choices].sort!
              options[:choices] << nil if has_nil
            end
            options
          end
          
          def add_page_links_defaults!(options)
            add_searchgasm_helper_defaults!(:page, options)
            options[:choices] ||= (1..options[:search_obj].page_count)
            options[:spead] ||= 3
            options[:prev] ||= "<"
            options[:next] ||= ">"
            options[:first] ||= "<<"
            options[:last] ||= ">>"
            options
          end
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::ControlTypes::Links if defined?(ActionController)