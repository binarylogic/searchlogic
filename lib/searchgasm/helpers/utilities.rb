module Searchgasm
  module Helpers #:nodoc:
    module Utilities # :nodoc:
      private
        # Adds default options for all helper methods.
        def add_searchgasm_helper_defaults!(option, options)
          options[:params_scope] = :search unless options.has_key?(:params_scope)
          options[:search_obj] ||= instance_variable_get("@#{options[:params_scope]}")
          raise(ArgumentError, "@search object could not be inferred, please specify: :search_obj => @search") unless options[:search_obj].is_a?(Searchgasm::Search::Base)
          options[:html] ||= {}
          options[:html][:class] ||= ""
          searchgasm_add_class!(options[:html], option)
          options
        end
        
        def searchgasm_url(url_hash, options)
          options[:params_scope].blank? ? url_hash : {options[:params_scope] => url_hash}
        end
        
        def searchgasm_url_hash(option, value, options)
          params_copy = params.deep_dup.with_indifferent_access
          params_copy.delete(:commit)
                    
          # Extract search params from params
          search_params = options[:params_scope].blank? ? params_copy : params_copy[options[:params_scope]]
          search_params ||= {}
          search_params = search_params.with_indifferent_access
                    
          # Never want to keep page
          search_params.delete(:page)
          
          # Use special order_by value
          search_params[option] = option == :order_by ? searchgasm_order_by_value(value) : value
          
          search_params
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
        
        # Need to deep dup a hash otherwise the "child" hashes get modified as its passed around
        def searchgasm_deep_dup(hash)
          new_hash = {}
          
          hash.each do |k, v|
            case v
            when Hash
              hash[k] = searchgasm_deep_dup(v)
            else
              hew_hash[k] = v
            end
          end
          
          new_hash
        end
    end
  end
end

ActionController::Base.helper(Searchgasm::Helpers::Utilities) if defined?(ActionController)