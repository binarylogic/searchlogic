module Searchgasm
  module Helpers #:nodoc:
    module UtilitiesHelper # :nodoc:
      private
        # Adds default options for all helper methods.
        def add_searchgasm_helper_defaults!(options, method_name, method_value = nil)
          options[:search_obj] ||= instance_variable_get(Config.search_obj_name)
          raise(ArgumentError, "@search object could not be inferred, please specify: :search_obj => @search)") unless options[:search_obj].is_a?(Searchgasm::Search::Base)
          method_value = stringify_everything(method_value) unless method_value.nil?
          options[:params_scope] = :search unless options.has_key?(:params_scope)
          options[:remote] = Config.remote_helpers? unless options.has_key?(:remote)
          
          if !options.has_key?(:action)
            if options[:type] == :select
              options[:action] = :onchange
            elsif options[:remote]
              options[:action] = :onclick
            end
          end
          
          options[:url] = searchgasm_url(options, method_name, method_value) unless options.has_key?(:url)

          options
        end
        
        def searchgasm_url(options, method_name, method_value = nil)
          params = (params || {}).dup
          params.delete(:commit)
          
          # Extract search params from params
          search_params = options[:params_scope].blank? ? params : params[options[:params_scope]] ||= {}
          
          # Rewrite :order_by and :per_page with what's in our search obj
          ([:order_by, :per_page] - [method_name]).each { |search_option| search_params[search_option] = options[:search_obj].send(search_option) }
          
          # Rewrite :conditions, separated due to unique call
          conditions = options[:search_obj].conditions.conditions
          search_params[:conditions] = conditions unless conditions.blank?
          
          # Never want to keep page or the option we are trying to set
          [:page, method_name].each { |option| search_params.delete(option) }
          
          # Alternate :order_by if we are ordering
          if method_name == :order_by
            search_params[:order_as] = (options[:search_obj].order_by == method_value && options[:search_obj].asc?) ? "DESC" : "ASC"
          else
            search_params[:order_as] = options[:search_obj].order_as
          end
          
          # Determine if this.value should be included or not, and set up url
          url = nil
          case options[:action]
          when :onchange
            # Include this.value
            url = url_for(params)
            url_option = CGI.escape((options[:params_scope].blank? ? "#{method_name}" : "#{options[:params_scope]}[#{method_name}]")) + "='+this.value"
            url += (url.last == "?" ? "" : (url.include?("?") ? "&amp;" : "?")) + url_option
          else
            # Build the plain URL
            search_params[method_name] = method_name == :order_by ? searchgasm_order_by_value(method_value) : method_value
            url = url_for(params)
          end
          
          # Now update options if remote
          if options[:remote]
            url = remote_function(:url => url, :method => :get).gsub(/\\'\+this.value'/, "'+this.value") + ";"
            
            update_fields = {method_name => method_value}
            update_fields[:order_as] = search_params[:order_as] if method_name == :order_by
            update_fields.each { |field, value| url += ";" + searchgasm_update_search_field_javascript(field, value, options) }
          elsif !options[:action].blank?
            # Add some javascript if its onclick
            url = "window.location = '" + url + ";"
          end
          
          url
        end
        
        def searchgasm_update_search_field_javascript(field, value, options)
          field_value = nil
          
          case options[:action]
          when :onchange
            field_value = "this.value";
          else
            field_value = field == :order_by ? searchgasm_order_by_value(value) : value
            field_value = "'#{CGI.escape(field_value)}'"
          end
          
          field_name = options[:params_scope] ? "#{options[:params_scope]}[#{field}]" : "#{field}"
          "#{field} = $('#{searchgasm_form_id(options[:search_obj])}').getInputs('hidden', '#{field_name}'); if(#{field}.length > 0) {  #{field}[0].value = #{field_value}; }"
        end
        
        def searchgasm_form_id(search_obj)
          "#{search_obj.klass.name.pluralize.underscore}_search_form"
        end
        
        def searchgasm_order_by_value(order_by)
          case order_by
          when String
            order_by
          when Array, Hash
            [Marshal.dump(order_by)].pack("m")
          end
        end
        
        def stringify_everything(obj)
          case obj
          when String
            obj
          when Symbol
            obj = obj.to_s
          when Array
            obj = obj.collect { |item| stringify_everything(item) }
          when Hash
            new_obj = {}
            obj.each { |key, value| new_obj[key.to_s] = stringify_everything(value) }
            new_obj
          end
        end
    end
  end
end

ActionController::Base.helper(Searchgasm::Helpers::UtilitiesHelper) if defined?(ActionController)