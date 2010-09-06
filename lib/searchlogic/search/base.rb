module Searchlogic
  class Search
    module Base
      def self.included(klass)
        klass.class_eval do
          attr_accessor :klass, :current_scope
          undef :id if respond_to?(:id)
        end
      end
      
      # Creates a new search object for the given class. Ex:
      #
      #   Searchlogic::Search.new(User, {}, {:username_like => "bjohnson"})
      def initialize(klass, current_scope, conditions = {})
        self.klass = klass
        self.current_scope = current_scope
        @conditions ||= {}
        self.conditions = conditions if conditions.is_a?(Hash)
      end

      def clone
        self.class.new(klass, current_scope && current_scope.clone, conditions.clone)
      end
    end
  end
end