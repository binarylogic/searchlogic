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
          link_options = options.deep_dup
          link_options.delete(:choices)
          html = ""
          options[:choices].each { |choice| html += order_by_link(choice, link_options.deep_dup) }
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
          link_options = options.deep_dup
          link_options.delete(:choices)
          html = ""
          options[:choices].each { |choice| html += order_as_link(choice, link_options.deep_dup) }
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
          link_options = options.deep_dup
          link_options.delete(:choices)
          html = ""
          options[:choices].each { |choice| html += per_page_link(choice, link_options.deep_dup) }
          html
        end
        
        # Creates a group of links that paginate through the data. Kind of like a flickr page navigation. This one has some nifty options.
        #
        # === Examples
        #
        #   page_links
        #   page_links(:first => "<< First", :last => "Last >>")
        #
        # === Classes and tag
        #
        # If the user is on the current page they will get a <span> tag, not an <a> tag. If they are on the first page the "first" and "prev" options will be a <span> also. The same goes
        # for "next" and "last" if the user is on the last page. Other than that each element will come with a CSS class so you can style it to your liking. Somtimes the easiest way to understand this
        # Is to either look at the example (linked in the README) or try it out and view the HTML source. It's pretty simple, but here are the explanations:
        #
        # * <tt>page</tt> - This is in *every* element, span or a.
        # * <tt>first_page</tt> - This is for the "first page" element only.
        # * <tt>preve_page</tt> - This is for the "prev page" element only.
        # * <tt>current_page</tt> - This is for the current page element
        # * <tt>next_page</tt> - This is for the "next page" element only.
        # * <tt>last_page</tt> - This is for the "last page" element only.
        # * <tt>disabled_page</tt> - Any element that is a span instead of an a tag.
        #
        # === Options
        #
        # Please look at per_page_link. All options there are applicable here and are passed onto each option.
        #
        # * <tt>:spread</tt> -- default: 3, set to nil to show all page, this represents how many choices available on each side of the current page
        # * <tt>:prev</tt> -- default: < Prev, set to nil to omit. This is an extra link on the left side of the page links that will go to the previous page
        # * <tt>:next</tt> -- default: Next >, set to nil to omit. This is an extra link on the right side of the page links that will go to the next page
        # * <tt>:first</tt> -- default: nil, set to nil to omit. This is an extra link on thefar left side of the page links that will go to the first page
        # * <tt>:last</tt> -- default: nil, set to nil to omit. This is an extra link on the far right side of the page links that will go to the last page
        def page_links(options = {})
          add_page_links_defaults!(options)
          return if options[:last_page] <= 1
          
          first_page = 0
          last_page = 0
          if !options[:spread].blank?
            first_page = options[:current_page] - options[:spread]
            first_page = options[:first_page] if first_page < options[:first_page]
            last_page = options[:current_page] + options[:spread]
            last_page = options[:last_page] if last_page > options[:last_page]
          else
            first_page = options[:first_page]
            last_page = options[:last_page]
          end
          
          html = ""
          html += span_or_page_link(:first, options.deep_dup, options[:current_page] == options[:first_page]) if options[:first]
          html += span_or_page_link(:prev, options.deep_dup, options[:current_page] == options[:first_page]) if options[:prev]
          (first_page..last_page).each { |page| html += span_or_page_link(page, options.deep_dup, page == options[:current_page]) }
          html += span_or_page_link(:next, options.deep_dup, options[:current_page] == options[:last_page]) if options[:next]
          html += span_or_page_link(:last, options.deep_dup, options[:current_page] == options[:last_page]) if options[:last]
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
            options[:first_page] ||= 1
            options[:last_page] ||= options[:search_obj].page_count
            options[:current_page] ||= options[:search_obj].page
            options[:spread] = 3 unless options.has_key?(:spread)
            options[:prev] = "< Prev" unless options.has_key?(:prev)
            options[:next] = "Next >" unless options.has_key?(:next)
            options
          end
          
          def span_or_page_link(name, options, span)
            text = ""
            page = 0
            case name
            when Fixnum
              text = name
              page = name
              searchgasm_add_class!(options[:html], "current_page") if span
            else
              text = options[name]
              page = options[:search_obj].send("#{name}_page")
              searchgasm_add_class!(options[:html], "#{name}_page")
            end
            
            searchgasm_add_class!(options[:html], "disabled_page") if span
            options[:text] = text
            span ? content_tag(:span, text, options[:html]) : page_link(page, options)
          end
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::ControlTypes::Links if defined?(ActionController)