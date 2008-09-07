module Searchgasm
  module Search
    module Conditions
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :initialize, :conditions
          alias_method_chain :conditions=, :conditions
          alias_method_chain :include, :conditions
          alias_method_chain :sanitize, :conditions
        end
      end
      
      def initialize_with_conditions(klass, init_options = {})
        self.conditions = Searchgasm::Conditions::Base.new(klass)
        initialize_without_conditions(klass, init_options)
      end
      
      # Sets conditions on the search. Accepts a hash or a Searchgasm::Conditions::Base object.
      def conditions_with_conditions=(values)
        case values
        when Searchgasm::Conditions::Base
          @conditions = values
        else
          @conditions.conditions = values
        end
      end
      
      def include_with_conditions
        includes = [include_without_conditions, conditions.includes].flatten.compact.uniq
        includes.blank? ? nil : (includes.size == 1 ? includes.first : includes)
      end
      
      def sanitize_with_conditions(for_method = nil)
        find_options = sanitize_without_conditions(for_method)
        find_options[:conditions] = find_options[:conditions].sanitize if find_options[:conditions]
        find_options
      end
      
      def scope
        conditions.scope
      end
      
      def scope=(value)
        conditions.scope = value
      end
    end
  end
end