module Searchgasm
  module Helpers
    module PaginationHelper
      # Creates navigation for paginating through a search
      #
      # === Options
      # Global options:
      # Please see Searchgasm::Helpers::Utilities.add_searchgasm_helper_defaults for all global options
      #
      # Local options:
      # * <tt>:type</tt> -- default: :select, pass :links as an alternative to have flickr like pagination
      # * <tt>:remote</tt> -- default: false, if true requests will be AJAX
      # * <tt>:html</tr> -- if :links then these will apply to the outermost <div>, if :select then these will apply to the select tag
      def pages(options = {})
        options[:type] ||= :select
        
        case options[:type]
        when :select
          options[:javascript] = true
        else
        end
        
        add_searchgasm_helper_defaults!(options, :page)
        return "" if options[:search].page_count <= 1
        
        case options[:type]
        when :select
          options[:html] ||= {}
          options[:html][:onchange] ||= ""
          options[:html][:onchange] += ";" + options[:url]
          select(:search, :page, (1..options[:search].page_count), {}, options[:html])
        else
          # HTML for links
        end
      end
      
      # Creates navigation for setting how many items per page
      #
      # === Options
      # Global options:
      # Please see Searchgasm::Helpers::Utilities.add_searchgasm_helper_defaults for all global options
      #
      # Local options:
      # * <tt>:type</tt> -- default: :select, pass :links as an alternative to links like: 10 | 25 | 50 | 100, etc
      # * <tt>:remote</tt> -- default: false, if true requests will be AJAX
      # * <tt>:choices</tt> -- default: [10, 25, 50, 100, 150, 200, nil], nil means "show all"
      # * <tt>:html</tr> -- if :links then these will apply to the outermost <div>, if :select then these will apply to the select tag
      def per_page(options = {})
        options[:javascript] = true
        add_searchgasm_helper_defaults!(options, :per_page)
        
        options[:choices] = [10, 25, 50, 100, 150, 200, nil]
        if !options[:search].per_page.blank? && !options[:choices].include?(options[:search].per_page)
          options[:choices] << options[:search].per_page
          options[:choices].sort!
        end
        options[:choices] = options[:choices].collect { |choice| [choice == nil ? "Show all" : "#{choice} per page", choice] }
                  
        #link_to "page 2", url_for(:search => {:page => 2, :per_page => 5, :conditions => options[:search].conditions(true)})
        options[:html] ||= {}
        options[:html][:onchange] ||= options[:url]
        
        select(:search, :per_page, options[:choices], {}, options[:html])
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::PaginationHelper if defined?(ActionController)