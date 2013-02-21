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
        def scope_procedure(name, &block)
          method_call = lambda do |klass, block, name|
              self.name do  
                block.call
              end
              puts "defined myself!"
          end

          define_method = lambda do |klass|
            method_call.call(klass, block, name)
          end

          binding.pry
          self.instance_eval(&define_method)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::ScopeProcedure)