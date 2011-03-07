module Searchlogic
  module ActiveRecord
    module AssociationProxy
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :send, :searchlogic
        end
      end

      def send_with_searchlogic(method, *args, &block)
        # create the scope if it doesn't exist yet, then delegate back to the original method
        if !proxy_respond_to?(method) && proxy_reflection.macro != :belongs_to && !proxy_reflection.options[:polymorphic] && proxy_reflection.klass.condition?(method)
          proxy_reflection.klass.send(method, *args, &block)
        end

        send_without_searchlogic(method, *args, &block)
      end
    end
  end
end