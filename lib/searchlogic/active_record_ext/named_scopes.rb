Dir[File.dirname(__FILE__) + '/named_scopes/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module NamedScopes
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def named_scopes 
          @named_scopes ||= {}
        end
      end
    end
  end
end

ActiveRecord::Base.__send__(:include, Searchlogic::ActiveRecordExt::NamedScopes)
