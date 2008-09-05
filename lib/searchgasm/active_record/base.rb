module Searchgasm
  module ActiveRecord
    module Base
      def calculate_with_searchgasm(*args)
        options = args.extract_options!
        options = sanitize_options_with_searchgasm(options)
        args << options
        calculate_without_searchgasm(*args)
      end
    
      def find_with_searchgasm(*args)
        options = args.extract_options!
        options = sanitize_options_with_searchgasm(options)
        args << options
        find_without_searchgasm(*args)
      end
    
      def scope_with_searchgasm(method, key = nil)
        scope = scope_without_searchgasm(method, key)
        return sanitize_options_with_searchgasm(scope) if key.nil? && method == :find && !scope.blank?
        scope
      end
    
      def build_conditions(values = {}, &block)
        conditions = searchgasm_conditions
        conditions.protect = true
        conditions.value = values
        yield conditions if block_given?
        conditions
      end
    
      def build_conditions!(values = {}, &block)
        conditions = searchgasm_conditions(values)
        yield conditions if block_given?
        conditions
      end
    
      def build_search(options = {}, &block)
        search = searchgasm_searcher
        search.protect = true
        search.options = options
        yield search if block_given?
        search
      end
    
      def build_search!(options = {}, &block)
        search = searchgasm_searcher(options)
        yield search if block_given?
        search
      end
      
      def conditions_protected(*conditions)
        write_inheritable_attribute(:conditions_protected, Set.new(conditions.map(&:to_s)) + (protected_conditions || []))
      end

      def protected_conditions
        read_inheritable_attribute(:conditions_protected)
      end
      
      def conditions_accessible(*conditions)
        write_inheritable_attribute(:conditions_accessible, Set.new(conditions.map(&:to_s)) + (protected_conditions || []))
      end

      def accessible_conditions
        read_inheritable_attribute(:conditions_accessible)
      end
    
      private
        def sanitize_options_with_searchgasm(options = {})
          return options unless Searchgasm::Search::Base.needed?(self, options)
          searchgasm_searcher(options).sanitize
        end
      
        def searchgasm_conditions(options = {})
          Searchgasm::Search::Conditions.new(self, options)
        end
      
        def searchgasm_searcher(options = {})
          Searchgasm::Search::Base.new(self, options)
        end
    end
  end
end

ActiveRecord::Base.send(:extend, Searchgasm::ActiveRecord::Base)

module ::ActiveRecord
  class Base
    class << self
      alias_method_chain :calculate, :searchgasm
      alias_method_chain :find, :searchgasm
      alias_method_chain :scope, :searchgasm
      alias_method :new_conditions, :build_conditions
      alias_method :new_conditions!, :build_conditions!
      alias_method :new_search, :build_search
      alias_method :new_search!, :build_search!
      
      def valid_find_options
         VALID_FIND_OPTIONS
       end
    end
  end
end