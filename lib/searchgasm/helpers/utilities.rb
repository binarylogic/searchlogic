module Searchgasm
  module Helpers #:nodoc:
    module Utilities # :nodoc:
      # Builds a hash of params for creating a url.
      def searchgasm_params(options = {})
        add_searchgasm_defaults!(options)
        options[:search_params] ||= {}
        options[:literal_search_params] ||= {}
        options[:params] ||= {}
        params_copy = params.deep_dup.with_indifferent_access
        search_params = options[:params_scope].blank? ? params_copy : params_copy.delete(options[:params_scope])
        search_params ||= {}
        search_params = search_params.with_indifferent_access
        search_params.delete(:commit)
        search_params.delete(:page)
        search_params.deep_delete_duplicates(options[:literal_search_params])
        
        if options[:search_params]
          search_params.deep_merge!(options[:search_params])
          
          if options[:search_params][:order_by] && !options[:search_params][:order_as]
            search_params[:order_as] = (options[:search_obj].order_by == options[:search_params][:order_by] && options[:search_obj].asc?) ? "DESC" : "ASC"
          end
        end
        
        new_params = params_copy
        new_params.deep_merge!(options[:params])
        
        if options[:params_scope].blank? || search_params.blank?
          new_params
        else
          new_params.merge(options[:params_scope] => search_params)
        end
      end
      
      def searchgasm_url(options = {})
        search_params = searchgasm_params(options)
        url = url_for(search_params)
        literal_param_strings = literal_param_strings(options[:literal_search_params], options[:params_scope].blank? ? "" : "#{options[:params_scope]}")
        url += (url.last == "?" ? "" : (url.include?("?") ? "&amp;" : "?")) + literal_param_strings.join("&amp;")
      end
      
      private
        # Adds default options for all helper methods.
        def add_searchgasm_defaults!(options)
          options[:params_scope] = :search unless options.has_key?(:params_scope)
          options[:search_obj] ||= instance_variable_get("@#{options[:params_scope]}")
          raise(ArgumentError, "@search object could not be inferred, please specify: :search_obj => @search or :params_scope => :search_obj_name") unless options[:search_obj].is_a?(Searchgasm::Search::Base)
          options
        end
        
        # Adds default options for all control type helper methods.
        def add_searchgasm_control_defaults!(option, options)
          add_searchgasm_defaults!(options)
          options[:html] ||= {}
          options[:html][:class] ||= ""
          searchgasm_add_class!(options[:html], option)
          options
        end
        
        def searchgasm_add_class!(html_options, new_class)
          new_class = new_class.to_s
          classes = html_options[:class].split(" ")
          classes << new_class unless classes.include?(new_class)
          html_options[:class] = classes.join(" ")
        end
        
        def searchgasm_order_by_value(order_by)
          case order_by
          when String
            order_by
          when Array, Hash
            [Marshal.dump(order_by)].pack("m")
          end
        end
        
        def searchgasm_state_for(option, options)
          @added_state_for ||= []
          html = ""
          unless @added_state_for.include?(option)
            value = options[:search_obj].send(option)
            html = hidden_field(options[:params_scope], option, :value => (option == :order_by ? searchgasm_order_by_value(value) : value))
            @added_state_for << option
          end
          html
        end
        
        def literal_param_strings(literal_params, prefix)
          param_strings = []
          
          literal_params.each do |k, v|
            param_string = prefix.blank? ? k.to_s : "#{prefix}[#{k}]"
            case v
            when Hash
              literal_param_strings(v, param_string).each do |literal_param_string|
                param_strings << literal_param_string
              end
            else
              param_strings << (CGI.escape(param_string) + "=#{v}")
            end
          end
          
          param_strings
        end
    end
  end
end

ActionController::Base.helper(Searchgasm::Helpers::Utilities) if defined?(ActionController)