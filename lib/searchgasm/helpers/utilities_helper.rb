module Searchgasm
  module Helpers
    module UtilitiesHelper
      # Requires that a search object be present. Either by explicitly passing it with the :search option or finding it view the @search instance variable
      def require_search(options = {}) #:nodoc:
        search = options[:search] || instance_variable_get(:@search)
        raise(ArgumentError, "@search object could not be inferred, please specify: order_by(:first_name, :search => @search)") unless search.is_a?(Searchgasm::Search::Base)
        search
      end
      
      # Adds default options for all helper methods.
      #
      # === Global Options
      # * <tt>:search</th> -- default: @search, this is your search object, if it is in an instance variable other than @search please pass it here
      # * <tt>:search_scope</th> -- default: :search, this is the scope in which your search params are held (params[:search]). This is required to preserve the search params.
      def add_searchgasm_helper_defaults!(options, method)
        options[:search] ||= instance_variable_get(:@search)
        raise(ArgumentError, "@search object could not be inferred, please specify: order_by(:first_name, :search => @search)") unless options[:search].is_a?(Searchgasm::Search::Base)
        
        options[:search_scope] ||= :search
        
        if options[:url].blank?
          p = (params || {}).dup
          if p[options[:search_scope]]
            p[options[:search_scope]].delete(method)
            p[options[:search_scope]].delete(:page) if [:per_page, :order_by].include?(method)
          end
          
          if options[:javascript]
            url = url_for(p)
            options[:url] = "window.location = '" + url + (url.last == "?" ? "" : (url.include?("?") ? "&amp;" : "?")) + "#{CGI.escape("#{options[:search_scope]}[#{method}]")}='+this.value;"
          else
            p[options[:search_scope]] ||= {}
            p[options[:search_scope]][method] = options[method]
            p[options[:search_scope]][:order_as] = options[:search].desc? ? "ASC" : "DESC" if method == :order_by
            options[:url] = url_for(p)
          end
        end
      end
    end
  end
end

ActionController::Base.helper(Searchgasm::Helpers::UtilitiesHelper) if defined?(ActionController)