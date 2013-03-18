module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class DescendBy < Condition
          def scope
            if applicable?
              klass.joins(join).order("#{order_on.to_s.pluralize}.#{sort_on} DESC")
            end
          end

            def self.matcher
              "descend_by"
            end
          private
            def applicable? 
              !(/^#{self.class.matcher}/ =~ method_name).nil?
            end
            def join 
              joins_values = klass.scoped.joins_values.flatten.last
            end

            def order_on 
              joins_values = Array(klass.scoped.joins_values.flatten.try(:last)).flatten
              potential_column = /descend_by_/.match(method_name).post_match
              if klass.column_names.include?(potential_column)
                klass.name.underscore.pluralize
              else
                Array(joins_values.last).flatten.last
              end
            end

            def sort_on
              args.first || /descend_by_(.*)/.match(method_name)[1]
            end
        end
      end
    end
  end
end