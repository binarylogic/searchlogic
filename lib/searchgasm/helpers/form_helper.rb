module Searchgasm
  module Helpers
    # = Form Helper
    #
    # Enables you to use form_for and fields_for just like you do with an ActiveRecord object.
    #
    # === Examples
    #
    # Let's assume @search is searching Address
    #
    #   form_for(@search) # is equivalent to form_for(:search, @search, :url => addresses_path)
    #   form_for([@current_user, @search]) # is equivalent to form_for(:search, @search, :url => user_addresses_path(@current_user))
    #   form_for([:admin, @search]) # is equivalent to form_for(:search, @search, :url => admin_addresses_path)
    #   form_for(:search, @search, :url => whatever_path)
    #
    # The goal was to mimic ActiveRecord. You can also pass a Searchgasm::Conditions::Base object as well and it will function the same way.
    #
    # === Automatic hidden fields generation
    #
    # If you pass a Searchgasm::Search::Base object it automatically adds the :order_by, :order_as, and :per_page hidden fields. This is done so that when someone
    # creates a new search, their options are remembered. It keeps the search consisten and is much more user friendly. If you want to override this you can pass the
    # following options. Or you can set this up in your configuration, see Searchgasm::Config for more details.
    #
    # === Options
    #
    # * <tt>:hidden_fields</tt> --- Array, a list of hidden fields to include. Defaults to [:order_by, :order_as, :per_page]. Pass false, nil, or a blank array to not include any.
    module FormHelper
      module Shared # :nodoc:
        private
          def searchgasm_object?(object)
            object.is_a?(Search::Base) || object.is_a?(Conditions::Base)
          end
        
          def find_searchgasm_object(args)
            case args.first
            when String, Symbol
              search_object = searchgasm_object?(args[1]) ? args[1] : instance_variable_get("@#{args.first}")
            when Array
              search_object = args.first.last
            else
              search_object = args.first
            end
          
            searchgasm_object?(search_object) ? search_object : nil
          end
        
          def searchgasm_args(args, search_object, for_helper = nil)
            args = args.dup
            first = args.shift
          
            # Setup args
            case first
            when String, Symbol
              args.unshift(search_object).unshift(first)
            else
              name = search_object.is_a?(Conditions::Base) ? (search_object.relationship_name || :conditions) : :search
              args.unshift(search_object).unshift(name)
            end
          
            if for_helper != :fields_for
              options = args.extract_options!
              options[:html] ||= {}
              options[:html][:method] ||= :get
              options[:method] ||= options[:html][:method] if for_helper == :remote_form_for
              options[:html][:id] ||= searchgasm_form_id(search_object)
          
              # Setup options
              case first
              when Array
                first.pop
                first << search_object.klass.new
                options[:url] ||= polymorphic_path(first)
              else
                options[:url] ||= polymorphic_path(search_object.klass.new)
              end
          
              args << options
            end
          
            args
          end
        
          def insert_searchgasm_fields(args, search_object)
            return unless search_object.is_a?(Search::Base)
            name = args.first
            options = args.extract_options!
            [(options.delete(:hidden_fields) || Config.hidden_fields)].flatten.each do |option|
              concat(hidden_field(name, option, :object => search_object, :value => (option == :order_by ? searchgasm_order_by_value(search_object.order_by) : search_object.send(option))))
            end
            args << options
          end
      end
      
      module Base # :nodoc:
        include Shared

        def fields_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            new_args = searchgasm_args(args, search_object, :fields_for)
            insert_searchgasm_fields(new_args, search_object)
            fields_for_without_searchgasm(*new_args, &block)
          else
            fields_for_without_searchgasm(*args, &block)
          end
        end
      
        def form_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            form_for_without_searchgasm(*searchgasm_args(args, search_object, :form_for), &block)
          else
            form_for_without_searchgasm(*args, &block)
          end
        end
      
        def remote_form_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            remote_form_for_without_searchgasm(*searchgasm_args(args, search_object, :remote_form_for), &block)
          else
            remote_form_for_without_searchgasm(*args, &block)
          end
        end
      end
    
      module FormBuilder # :nodoc:
        include Shared
        
        def fields_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            new_args = searchgasm_args(args, search_object, :fields_for)
            insert_searchgasm_fields(new_args, search_object)
            fields_for_without_searchgasm(*new_args, &block)
          else
            fields_for_without_searchgasm(*args, &block)
          end
        end
      end
    end
  end
end

if defined?(ActionView)
  ActionView::Base.send(:include, Searchgasm::Helpers::FormHelper::Base)

  ActionView::Base.class_eval do
    alias_method_chain :fields_for, :searchgasm
    alias_method_chain :form_for, :searchgasm
    alias_method_chain :remote_form_for, :searchgasm
  end

  ActionView::Helpers::FormBuilder.send(:include, Searchgasm::Helpers::FormHelper::FormBuilder)

  ActionView::Helpers::FormBuilder.class_eval do
    alias_method_chain :fields_for, :searchgasm
  end
end