module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Or < Condition
          def scope
            if applicable?
              method_without_ending_condition = method_name.to_s.chomp(ending_alias_condition)
              methods = join_equal_to(method_without_ending_condition.split("_or_"))
              results = methods.map do |m| 
                klass.send(add_condition(m), value)
              end
              ##need to return ActiveRecord::Relation object, combining 'where_values' from individual scopes fails when
              ##scope is an association so collect the results and run a where clause vs their id's to return correct results
              ##and an ActiveRecord::Relation
              ids = results.flatten.uniq.map(&:id)
              klass.where("id in (?)", ids)
            end
          end

            def self.matcher
              nil
            end
          private

            def join_equal_to(method_array)
              methods = []
              method_array.each_with_index do |item, index| 
                if item == "equal" || item == "equal_to"
                  methods.delete_at(-1)
                  methods << [method_array[index-1], item ].join("_or_")
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
              has_condition?(method) ? method : method + ending_alias_condition
            end

            def has_condition?(method)
              !!(/(#{ScopeReflection.aliases.join("|")}|#{self.class.all_matchers.join("|")})/.match(method))
            end

            def ending_alias_condition 
              /(_#{self.class.all_matchers.sort_by(&:size).reverse.join("|")})$/.match(method_name)[0]
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

