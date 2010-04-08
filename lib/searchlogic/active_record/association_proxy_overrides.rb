module Searchlogic
  module ActiveRecord
    module AssociationProxyOverrides
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :send, :preload_searchlogic_or_conditions
          alias_method_chain :send, :preload_searchlogic_conditions
          alias_method_chain :send, :preload_searchlogic_ordering
        end
      end
      
      def send_with_preload_searchlogic_conditions(name, *args, &block)
        if details=condition_details(name)
          create_condition(details[:column], details[:condition], args)
          send_without_preload_searchlogic_conditions(name, *args)
        elsif boolean_condition?(name)
          column = name.to_s.gsub(/^not_/, "")
          named_scope name, :conditions => {column => (name.to_s =~ /^not_/).nil?}
          send_without_preload_searchlogic_conditions(name)
        else
          send_without_preload_searchlogic_conditions(name, *args, &block)
        end
      end
      
      def send_with_preload_searchlogic_ordering(name, *args, &block)
        if name == :order
          named_scope name, lambda { |scope_name|
            return {} if !condition?(scope_name)
            send_without_preload_searchlogic_ordering(scope_name).proxy_options
          }
          send_without_preload_searchlogic_ordering(name, *args)
        elsif details = ordering_condition_details(name)
          create_ordering_conditions(details[:column])
          send_without_preload_searchlogic_ordering(name, *args)
        else
          send_without_preload_searchlogic_ordering(name, *args, &block)
        end
      end
      
      def send_with_preload_searchlogic_or_conditions(name, *args, &block)
        if conditions = or_conditions(name)
          create_or_condition(conditions, args)
          proxy_reflection.klass.class_eval do
            (class << self; self; end).class_eval { alias_method name, conditions.join("_or_") } if !respond_to?(name)
          end
          send_without_preload_searchlogic_or_conditions(name, *args)
        else
          send_without_preload_searchlogic_or_conditions(name, *args, &block)
        end
      end
    end
  end
end