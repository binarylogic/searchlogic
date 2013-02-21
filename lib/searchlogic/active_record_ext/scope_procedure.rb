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
        def metaclass
          class << self; self; end
        end
        def scope_procedure(name, &block)
          metaclass.instance_eval do 
            define_method(name) do
              block.call
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::ScopeProcedure)
