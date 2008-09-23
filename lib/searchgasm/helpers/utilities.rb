module Searchgasm
  module Helpers #:nodoc:
    module Utilities # :nodoc:
      # Builds a hash of params for creating a url.
      def searchgasm_params(option, options = {})
        add_searchgasm_defaults!(options)
        params_copy = params.deep_dup.with_indifferent_access
        params_copy.delete(:commit)
        
        # Extract search params from params
        search_params = options[:params_scope].blank? ? params_copy : params_copy[options[:params_scope]]
        search_params ||= {}
        search_params = search_params.with_indifferent_access
        
        # Never want to keep page
        search_params.delete(:page)
        
        option_params = search_params
        
        if option.is_a?(Array)
          option_levels = option.up
          option = option_levels.pop
          option_levels.each { |option_level| options_params = options_params[option_level] }
        end
        
        if options[:value]
          option_params[option] = option == :order_by ? searchgasm_order_by_value(options[:value]) : options[:value]
          
          case option
          when :order_by
            option_params[:order_as] = (options[:search_obj].order_by == options[:value] && options[:search_obj].asc?) ? "DESC" : "ASC"
          end
        else
          option_params.delete(option)
        end
        
        options[:params_scope].blank? ? search_params : {options[:params_scope] => search_params}
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
    end
  end
end

ActionController::Base.helper(Searchgasm::Helpers::Utilities) if defined?(ActionController)