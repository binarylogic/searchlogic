module Searchlogic
  module ActiveRecordExt
    module SearchProxy
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def searchlogic(conditions = {}) 
          Search.new(self.scoped , conditions)
        end
        alias_method :search, :searchlogic
      end
    end
  end
end

ActiveRecord::Base.__send__(:include, Searchlogic::ActiveRecordExt::SearchProxy)