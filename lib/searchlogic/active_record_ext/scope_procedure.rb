Dir[File.dirname(__FILE__) + '/scope_procedure/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def searchlogic_scopes 
          @searchlogic_scopes ||= []
        end
        
        def scope_procedure(name, block)
          singleton_class.instance_eval do
              define_method(name) do |value|
                block.call(value)
            end
          end
          searchlogic_scopes.push(name)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::ScopeProcedure)
