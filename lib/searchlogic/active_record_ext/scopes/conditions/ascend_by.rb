module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class AscendBy < Condition
          def scope
            if applicable?
              sort_on = find_sort_on(method_name)
              klass.order("#{sort_on} ASC")
            end
          end

          private

            def applicable?
              !(/ascend_by_/ =~ method_name).nil?
            end

            def find_sort_on(method)
              /ascend_by_(.*)/.match(method)[1]
            end
        end
      end
    end
  end
end