module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Any < Condition
          def scope
            if applicable?
              where_values = value.map{|arg| klass.send(new_method, arg).where_values}.
                            flatten.
                            join(" OR ")
              klass.where(where_values)
            end
          end

          private
            def new_method
              /(.*)_any/.match(method_name)[1]
            end
            def chained_method

              value.map{|arg| new_method + "#{arg}" + "_or_"}.join
            end
            def value
              args.flatten
            end
            def applicable? 
              !(/_any/ =~ method_name).nil?
            end
        end
      end
    end
  end
end

