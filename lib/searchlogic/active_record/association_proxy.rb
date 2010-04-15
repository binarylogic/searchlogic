module Searchlogic
  module ActiveRecord
    module AssociationProxy
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :send, :searchlogic
        end
      end
      
      def send_with_searchlogic(method, *args)
        if !proxy_respond_to?(method) && !proxy_reflection.options[:polymorphic] && proxy_reflection.klass.condition?(method)
          proxy_reflection.klass.send(method, *args)
        else
          send_without_searchlogic(method, *args)
        end
      end
    end
  end
end