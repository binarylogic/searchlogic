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
          method_call = lambda { puts "block.called HEre" }
          define_method = lambda do |klass, method_call|
            puts "#{klass}"
            method_call.call
            def cool
              method_call.call
            end
          end
          binding.pry
          self.instance_eval(&define_method(method_call))
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::ScopeProcedure)