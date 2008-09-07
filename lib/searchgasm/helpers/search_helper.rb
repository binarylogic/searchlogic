module Searchgasm
  module Helpers
    # = Search Helper
    #
    # Helper methods for paginating and ordering through a search.
    module SearchHelper
      # Creates a link for ordering data in a certain way. See Searchgasm::Config for setting default configuration.
      #
      # === Example uses for a User class that has many orders
      #   order_by(:first_name)
      #   order_by([:first_name, :last_name])
      #   order_by({:orders => :total})
      #   order_bt([{:orders => :total}, :first_name])
      #
      # If the output just isn't cutting it for you, then you can pass it a block and it will spit out the result of the block. The block is passed "options" which is all of the information you should need
      # for doing whatever you need to do. It's the options you are allowed to pass, but with their proper values.
      #
      #   <%= order_by(:id) { |options| link_to(options[:text], options[:url], options[:html]) } %>
      #
      # or
      #
      #   <% order_by(:id) do |options| %><%= link_to(options[:text], options[:url]) %><% end %>
      #
      # Another thing to keep in mind is that the value gets "serialized", if it is not a string or a simple, so that it can be passed via a param in the url. Searchgasm will automatically try to "unserializes" this value and use it. This allows you
      # to pass complex objects besides strings and symbols, such as arrays and hashes.
      #
      # === Options
      # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
      # * <tt>:desc_indicator</tt> -- default: &nbsp;&#9660;, the indicator that this column is descending
      # * <tt>:asc_indicator</tt> -- default: &nbsp;&#9650;, the indicator that this column is ascending
      #
      # === Advanced Options
      # * <tt>:action</tt> -- this is automatically determined for you based on the type. For a :select type, its :onchange. For a :links type, its :onclick. You shouldn't have to use this option unless you are doing something out of the norm. The point of this option is to return a URL that will include this.value or not
      # * <tt>:url</tt> -- default: uses url_for to preserve your params and search, I can not think of a reason to pass this, but its there just incase
      # * <tt>:html</tt> -- if type is :links then these will apply to the outermost <div>, if type is :select then these will apply to the select tag
      # * <tt>:search_obj</tt> -- default: @search, this is your search object, if it is in an instance variable other than @search please pass it here. Ex: :@my_search, or :my_search
      # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
      def order_by(column_name, options = {}, &block)
        add_searchgasm_helper_defaults!(options, :order_by, column_name)
        column_name = stringify_everything(column_name)
        options[:text] = determine_order_by_text(column_name) unless options.has_key?(:text)
        options[:asc_indicator] ||= Config.asc_indicator
        options[:desc_indicator] ||= Config.desc_indicator
        options[:text] += options[:search_obj].desc? ? options[:desc_indicator] : options[:asc_indicator] if options[:search_obj].order_by == column_name
        
        if block_given?
          yield options
        else
          if options[:remote]
            link_to_function(options[:text], options[:url], options[:html])
          else
            link_to(options[:text], options[:url], options[:html])
          end
        end
      end
      
      # Creates navigation for paginating through a search. See Searchgasm::Config for setting default configuration.
      #
      # === Examples
      #   pages
      #   pages(:search => @my_search)
      #   pages(:html => {:id => "my_id"})
      #
      # If the output just isn't cutting it for you, then you can pass it a block and it will spit out the result of the block. The block is passed "options" which is all of the information you should need
      # for doing whatever you need to do. It's the options you are allowed to pass, but with their proper values.
      #
      #   <%= pages { |options| select(:search, :page, (1..options[:search_obj].page_count), {}, options[:html]) } %>
      #
      # or
      #
      #   <% pages do |options| %><%= select(:search, :page, (1..options[:search_obj].page_count), {}, options[:html]) %><% end %>
      #
      # === Options
      # * <tt>:type</tt> -- default: :select, pass :links as an alternative to have flickr like pagination
      # * <tt>:remote</tt> -- default: false, if true requests will be AJAX
      #
      # === Advanced Options
      # * <tt>:action</tt> -- this is automatically determined for you based on the type. For a :select type, its :onchange. For a :links type, its :onclick. You shouldn't have to use this option unless you are doing something out of the norm. The point of this option is to return a URL that will include this.value or not
      # * <tt>:url</tt> -- default: uses url_for to preserve your params and search, I can not think of a reason to pass this, but its there just incase
      # * <tt>:html</tt> -- if type is :links then these will apply to the outermost <div>, if type is :select then these will apply to the select tag
      # * <tt>:search_obj</tt> -- default: @search, this is your search object, if it is in an instance variable other than @search please pass it here. Ex: :@my_search, or :my_search
      # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
      def pages(options = {})
        options[:type] ||= Config.pages_type
        add_searchgasm_helper_defaults!(options, :page)
        return "" if options[:search_obj].page_count <= 1
        
        if block_given?
          yield options
        else
          case options[:type]
          when :select
            options[:html] ||= {}
            options[:html][options[:action]] ||= ""
            options[:html][options[:action]] += ";"
            options[:html][options[:action]] += options[:url]
            select(:search, :page, (1..options[:search_obj].page_count), {}, options[:html])
          else
            # HTML for links
          end
        end
      end
      
      # Creates navigation for setting how many items per page. See Searchgasm::Config for setting default configuration.
      #
      # === Examples
      #   per_page
      #   per_page(:search => @my_search)
      #   per_page(:choices => [50, 100])
      #   per_page(:html => {:id => "my_id"})
      #
      # If the output just isn't cutting it for you, then you can pass it a block and it will spit out the result of the block. The block is passed "options" which is all of the information you should need
      # for doing whatever you need to do. It's the options you are allowed to pass, but with their proper values.
      #
      #   <%= per_page { |options| select(:search, :per_page, options[:choices], {}, options[:html]) } %>
      #
      # or
      #
      #   <% per_page do |options| %><%= select(:search, :per_page, options[:choices], {}, options[:html]) %><% end %>
      #
      # === Options
      # * <tt>:type</tt> -- default: :select, pass :links as an alternative to links like: 10 | 25 | 50 | 100, etc
      # * <tt>:remote</tt> -- default: false, if true requests will be AJAX
      # * <tt>:choices</tt> -- default: [10, 25, 50, 100, 150, 200, nil], nil means "show all"
      #
      # === Advanced Options
      # * <tt>:choices</tt> -- default: [10, 25, 50, 100, 150, 200, nil], nil means "show all"
      # * <tt>:action</tt> -- this is automatically determined for you based on the type. For a :select type, its :onchange. For a :links type, its :onclick. You shouldn't have to use this option unless you are doing something out of the norm. The point of this option is to return a URL that will include this.value or not
      # * <tt>:url</tt> -- default: uses url_for to preserve your params and search, I can not think of a reason to pass this, but its there just incase
      # * <tt>:html</tt> -- if type is :links then these will apply to the outermost <div>, if type is :select then these will apply to the select tag
      # * <tt>:search_obj</tt> -- default: @search, this is your search object, if it is in an instance variable other than @search please pass it here. Ex: :@my_search, or :my_search
      # * <tt>:params_scope</tt> -- default: :search, this is the scope in which your search params will be preserved (params[:search]). If you don't want a scope and want your options to be at base leve in params such as params[:page], params[:per_page], etc, then set this to nil.
      def per_page(options = {})
        options[:type] ||= Config.per_page_type
        add_searchgasm_helper_defaults!(options, :per_page)
        
        options[:choices] ||= Config.per_page_choices
        if !options[:search_obj].per_page.blank? && !options[:choices].include?(options[:search_obj].per_page)
          options[:choices] << options[:search_obj].per_page
          has_nil = options[:choices].include?(nil)
          options[:choices].delete(nil) if has_nil
          options[:choices].sort!
          options[:choices] << nil if has_nil
        end
        options[:choices] = options[:choices].collect { |choice| [choice == nil ? "Show all" : "#{choice} per page", choice] }
                
        if block_given?
          yield options
        else
          case options[:type]
          when :select
            options[:html] ||= {}
            options[:html][options[:action]] ||= ""
            options[:html][options[:action]] += ";"
            options[:html][options[:action]] += options[:url]
            select(:search, :per_page, options[:choices], {}, options[:html])
          end
        end
      end
      
      private
        def determine_order_by_text(column_name, relationship_name = nil)
          case column_name
          when String, Symbol
            relationship_name.blank? ? column_name.titleize : "#{relationship_name.titleize} #{column_name.titleize}"
          when Array
            determine_order_by_text(column_name.last)
          when Hash
            k = column_name.keys.first
            v = column_name.values.first
            determine_order_by_text(v, k)
          end
        end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::SearchHelper if defined?(ActionController)