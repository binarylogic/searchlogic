module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Boolean < Condition 
          def scope
            if applicable?
              klass.where("#{table_name}.#{method_name.to_s} = ?", true)
            end
          end

          def self.matcher
            nil
          end

          def applicable?
            klass.column_names.include?(method_name.to_s) && klass.columns.find{|column| column.name == method_name.to_s}.type == :boolean
          end
        end
      end
    end
  end
end
