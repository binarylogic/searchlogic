module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions

        class Oor < Condition
          def scope
            if applicable?
              methods = method_name.to_s.split("_or_")
              methods.map { |m| klass.send(add_condition(m), value) }.flatten
            end
          end

          private
            def find_condition
              klass.joined_condition_klasses.split("|").find{ |jck| last_method.include?(jck)}
            end

            def add_condition(method)
              if alias_used?(method_name)
                alias_used?(method) ? method : method + ending_alias_condition
              else
                find_condition ? method : method + "_" + find_condition
              end
            end

            def alias_used?(method)
              !(klass.column_names.find{|c| Regexp.new(c + "_") =~ method }.nil?)
            end
            
            
            def last_method 
              method_name.to_s.split("_or_").last
            end

            def ending_alias_condition
              column = klass.column_names.find{|c| last_method.include?(c) }
              method, alias_used = last_method.split(column)
              alias_used
            end

            def applicable? 
              !(/_or_/ =~ method_name).nil?
            end
        end
      end
    end
  end
end

