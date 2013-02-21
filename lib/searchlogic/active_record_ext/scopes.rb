require 'active_record'
Dir[File.dirname(__FILE__) + '/scopes/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module Scopes
      def self.included(klass)
        klass.instance_eval do 
          extend Conditions
        end
      end
      module Conditions
        private
          def method_missing(method, *args, &block) 
            return memoized_scope[method] if memoized_scope[method]
            generate_scope(method, args, &block) || super
          end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::Scopes)

