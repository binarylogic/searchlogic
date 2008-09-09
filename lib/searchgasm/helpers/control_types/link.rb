module Searchgasm
  module Helpers
    module ControlTypes
      # = Link Control Types
      #
      # These helpers make ordering and paginating your data a breeze in your view. They only produce links.
      module Link
        # Creates a link for ordering data by a column or columns
        #
        # === Example uses for a User class that has many orders
        #
        #   order_by_link(:first_name)
        #   order_by_link([:first_name, :last_name])
        #   order_by_link({:orders => :total})
        #   order_by_link([{:orders => :total}, :first_name])
        #   order_by_link(:id, :text => "Order Number", :html => {:class => "order_number"})
        #
        # What's nifty about this is that the value gets "serialized", if it is not a string or a symbol, so that it can be passed via a param in the url. Searchgasm will automatically try to "unserializes" this value and use it. This allows you
        # to pass complex objects besides strings and symbols, such as arrays and hashes. All of the hard work is done for you.
        #
        # Another thing to keep in mind is that this will alternate between "asc" and "desc" each time it is clicked.
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:desc_indicator</tt> -- default: &nbsp;&#9660;, the indicator that this column is descending
        # * <tt>:asc_indicator</tt> -- default: &nbsp;&#9650;, the indicator that this column is ascending
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        def order_by_link(order_by, options = {})
          order_by = deep_stringify(order_by)
          add_order_by_link_defaults!(order_by, options)
          html = searchgasm_state_for(:order_by, options) + searchgasm_state_for(:order_as, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        # Creates a link for ascending or descending data, pretty self e
        #
        # === Example uses
        #
        #   order_as_link("asc")
        #   order_as_link("desc")
        #   order_as_link("asc", :text => "Ascending", :html => {:class => "ascending"})
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        def order_as_link(order_as, options = {})
          add_order_as_link_defaults!(order_as, options)
          html = searchgasm_state_for(:order_as, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        # Creates a link for limiting how many items are on each page
        #
        # === Example uses
        #
        #   per_page_link(200)
        #   per_page_link(nil) # => Show all
        #   per_page_link(nil, :text => "All", :html => {:class => "show_all"})
        #
        # As you can see above, passing nil means "show all" and the text will automatically revert to "show all"
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        def per_page_link(per_page, options = {})
          add_per_page_link_defaults!(per_page, options)
          html = searchgasm_state_for(:per_page, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        # Creates a link for changing to a sepcific page of your data
        #
        # === Example uses
        #
        #   page_link(2)
        #   page_link(1)
        #   page_link(5, :text => "Fifth page", :html => {:class => "fifth_page"})
        #
        # === Options
        # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
        # * <tt>:html</tt> -- html arrtributes for the <a> tag.
        #
        # === Advanced Options
        # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
        # * <tt>:search_obj</tt> -- default: @#{params_scope}, this is your search object, everything revolves around this. It will try to infer the name from your params_scope. If your params_scope is :search it will try to get @search, etc. If it can not be inferred by this, you need to pass the object itself.
        def page_link(page, options = {})
          add_page_link_defaults!(page, options)
          html = searchgasm_state_for(:page, options)
          
          if !options[:is_remote]
            html += link_to(options[:text], options[:url], options[:html])
          else
            html += link_to_remote(options[:text], options[:remote].merge(:url => options[:url]), options[:html])
          end
          
          html
        end
        
        private
          def add_order_by_link_defaults!(order_by, options = {})
            add_searchgasm_helper_defaults!(:order_by, options)
            options[:text] ||= determine_order_by_text(order_by)
            options[:asc_indicator] ||= Config.asc_indicator
            options[:desc_indicator] ||= Config.desc_indicator
            options[:text] += options[:search_obj].desc? ? options[:desc_indicator] : options[:asc_indicator] if options[:search_obj].order_by == order_by
            url_hash = searchgasm_url_hash(:order_by, order_by, options)
            url_hash[:order_as] = (options[:search_obj].order_by == order_by && options[:search_obj].asc?) ? "DESC" : "ASC"
            options[:url] = searchgasm_url(url_hash, options)
            options
          end
          
          def add_order_as_link_defaults!(order_as, options = {})
            add_searchgasm_helper_defaults!(:order_as, options)
            options[:text] ||= order_as.to_s
            options[:url] = searchgasm_url(searchgasm_url_hash(:order_as, order_as, options), options)
            options
          end
          
          def add_per_page_link_defaults!(per_page, options = {})
            add_searchgasm_helper_defaults!(:per_page, options)
            options[:text] ||= per_page.blank? ? "Show all" : "#{per_page} per page"
            options[:url] = searchgasm_url(searchgasm_url_hash(:per_page, per_page, options), options)
            options
          end
          
          def add_page_link_defaults!(page, options = {})
            add_searchgasm_helper_defaults!(:page, options)
            options[:text] ||= page.to_s
            options[:url] = searchgasm_url(searchgasm_url_hash(:page, page, options), options)
            options
          end
          
          def determine_order_by_text(column_name, relationship_name = nil)
            case column_name
            when String, Symbol
              relationship_name.blank? ? column_name.to_s.titleize : "#{relationship_name.to_s.titleize} #{column_name.to_s.titleize}"
            when Array
              determine_order_by_text(column_name.first)
            when Hash
              k = column_name.keys.first
              v = column_name.values.first
              determine_order_by_text(v, k)
            end
          end
          
          def deep_stringify(obj)
            case obj
            when String
              obj
            when Symbol
              obj = obj.to_s
            when Array
              obj = obj.collect { |item| deep_stringify(item) }
            when Hash
              new_obj = {}
              obj.each { |key, value| new_obj[key.to_s] = deep_stringify(value) }
              new_obj
            end
          end
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::ControlTypes::Link if defined?(ActionController)