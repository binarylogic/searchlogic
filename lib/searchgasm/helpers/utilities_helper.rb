module BinaryLogic
  module Searchgasm
    module Helpers
      module UtilitiesHelper
        def require_search(options = {})
          search = options[:search] || instance_variable_get(:@search)
          raise(ArgumentError, "@search object could not be inferred, please specify: order_by(:first_name, :search => @search)") unless search.is_a?(BinaryLogic::Searchgasm::Search::Base)
          search
        end
        
        def add_searchgasm_helper_defaults!(options, method)
          options[:search] ||= instance_variable_get(:@search)
          raise(ArgumentError, "@search object could not be inferred, please specify: order_by(:first_name, :search => @search)") unless options[:search].is_a?(BinaryLogic::Searchgasm::Search::Base)
          
          options[:form_scope] ||= :search
          
          if options[:url].blank?
            p = (params || {}).dup
            if p[options[:form_scope]]
              p[options[:form_scope]].delete(method)
              p[options[:form_scope]].delete(:page) if [:per_page, :order_by].include?(method)
            end
            
            if options[:javascript]
              url = url_for(p)
              options[:url] = "window.location = '" + url + (url.last == "?" ? "" : (url.include?("?") ? "&amp;" : "?")) + "#{CGI.escape("#{options[:form_scope]}[#{method}]")}='+this.value;"
            else
              p[options[:form_scope]] ||= {}
              p[options[:form_scope]][method] = options[method]
              p[options[:form_scope]][:order_as] = options[:search].desc? ? "ASC" : "DESC" if method == :order_by
              options[:url] = url_for(p)
            end
          end
        end
      end
    end
  end
end

ActionController::Base.helper(BinaryLogic::Searchgasm::Helpers::UtilitiesHelper) if defined?(ActionController)