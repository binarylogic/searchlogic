module Searchgasm
  module Helpers
    module FormHelper
      module Shared
        
        def searchgasm_object?(object)
          object.is_a?(Search::Base) || object.is_a?(Search::Conditions)
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
        
        def searchgasm_args(args, search_object, fields_for = false)
          args = args.dup
          first = args.shift
          
          # Setup args
          case first
          when String, Symbol
            args.unshift(search_object).unshift(first)
          else
            name = search_object.is_a?(Search::Conditions) ? (search_object.relationship_name || :conditions) : :search
            args.unshift(search_object).unshift(name)
          end
          
          if !fields_for
            options = args.extract_options!
            options[:html] ||= {}
            options[:html][:method] ||= :get
            #options[:html][:id] ||= searchgasm_form_id(search_object)
          
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
          (Search::Base::SPECIAL_FIND_OPTIONS - [:page]).each do |option|
            concat(hidden_field(name, option, :object => search_object)) unless options.delete(option) == false
          end
          args << options
        end
      end
      
      module Base
        include Shared

        def fields_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            new_args = searchgasm_args(args, search_object, true)
            insert_searchgasm_fields(new_args, search_object)
            fields_for_without_searchgasm(*new_args, &block)
          else
            fields_for_without_searchgasm(*args, &block)
          end
        end
      
        def form_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            form_for_without_searchgasm(*searchgasm_args(args, search_object), &block)
          else
            form_for_without_searchgasm(*args, &block)
          end
        end
      
        def remote_form_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            remote_form_for_without_searchgasm(*searchgasm_args(args, search_object), &block)
          else
            remote_form_for_without_searchgasm(*args, &block)
          end
        end
      end
    
      module FormBuilder
        include Shared
        
        def fields_for_with_searchgasm(*args, &block)
          search_object = find_searchgasm_object(args)
          if search_object
            new_args = searchgasm_args(args, search_object, true)
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