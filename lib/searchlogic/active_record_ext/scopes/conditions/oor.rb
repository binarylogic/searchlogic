module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions

        class Oor < Condition
          def scope
            if applicable?
              method_without_ending_condition = method_name.to_s.chomp(ending_alias_condition)
              methods = join_equal_to(method_without_ending_condition.split("_or_"))
              where_values = methods.map do |m| 
                klass.send(add_condition(m), value) 
              end.flatten.uniq
              # binding.pry
              # klass.where(where_values.join(" OR "))
            end
          end

          private

            def join_equal_to(method_array)
              methods = []
              method_array.each_with_index do |item, index| 
                if item == "equal" || item == "equal_to"
                  methods << [method_array[index-1], item ].join("_or_")
                  methods.delete_at(index-1)
                else
                  methods << item
                end
              end
              methods
            end

            def find_condition
              klass.joined_condition_klasses.split("|").find{ |jck| last_method.include?(jck)}
            end

            def add_condition(method)
              if column_name?(method) || association?(method)
                method + ending_alias_condition
              else
                method            
              end
            end

            def column_name?(method)
              !!(klass.column_names.find{|kcn| kcn.to_s == method.to_s})
            end

            def association?(method)
              !!(klass.reflect_on_all_associations.find{|ass| method.to_s.include?(ass.name.downcase.to_s)})
            end
            
            def ending_alias_condition 
              /(#{klass.sl_conditions.split("|").sort_by(&:size).reverse.join("|")})$/.match(method_name)[0]
            end

            def applicable? 
              return nil if /(find_or_create)/ =~ method_name 
              !(/_or_(#{klass.column_names.join("|")}|#{klass.reflect_on_all_associations.map(&:name).join("|")})/ =~ method_name).nil? 
            end
        end
      end
    end
  end
end

