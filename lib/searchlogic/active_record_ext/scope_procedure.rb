Dir[File.dirname(__FILE__) + '/scope_procedure/*.rb'].each { |f| require(f) }

module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      def self.included(klass)
        klass.instance_eval do
          extend ClassMethods
          singleton_class.instance_eval do 
            define_method(:searchlogic_scopes) do 
              @searchlogic_scopes ||= []
            end  
          end
        end
      end

      module ClassMethods
        def scope_procedure(name, &block)
          singleton_class.instance_eval do 
            define_method(name) do
              block.call
            end
          end
          searchlogic_scopes.push(name)
          ActiveRecord::Base.searchlogic_scopes.push(name) 
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::ScopeProcedure)
