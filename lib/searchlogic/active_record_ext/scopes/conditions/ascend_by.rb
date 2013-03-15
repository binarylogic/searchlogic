module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class AscendBy < Condition
          def scope
            if applicable?
              klass.joins(join).order("#{order_on.to_s.pluralize}.#{sort_on} ASC")
            end
          end

          def self.matcher
            "ascend_by"
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
              if joins_values.empty?
                klass.name.underscore.pluralize
              else
                Array(joins_values.last).flatten.last
              end
            end

            def sort_on
              args.first || /ascend_by_(.*)/.match(method_name)[1]
            end
        end
      end
    end
  end
end