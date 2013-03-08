module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Or < Condition
          def scope
            if applicable?
              results = methods_array.map do |m| 
                if klass.named_scopes.keys.include?(m.to_sym)
                  if klass.named_scopes[m.to_sym][:scope].arity == 0
                    klass.send(m) 
                  else
                    klass.send(m, *value)
                  end
                else
                  klass.send(add_condition(m), *value)
                end
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

          def value
            args.size == 1 ? args.first : args
          end


          def methods_array
            join_equal_to(method_without_ending_condition.split("_or_"))            
          end
          def method_without_ending_condition
            method_name.to_s.chomp(ending_alias_condition)
          end

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
              if has_condition?(method) && ending_alias_condition != "_any" && ending_alias_condition != "_all"
                method 
              else
                method + ending_alias_condition
              end
            end

            def has_condition?(method)
              !!(/(#{ScopeReflection.aliases.join("|")}|#{self.class.all_matchers.join("|")})/.match(method))
            end

            def ending_alias_condition 
              return nil if /#{ScopeReflection.joined_named_scopes}$/ =~ method_name && ScopeReflection.joined_named_scopes
              begin
                /(#{self.class.all_matchers.sort_by(&:size).reverse.join("|")})$/.match(method_name)[0]
              rescue NoMethodError
                raise NoConditionError.new
              end
            end

            def applicable? 
              return nil if /(find_or_create)/ =~ method_name 
              named_scopes = klass.named_scopes.keys.map(&:to_s).join("|")
              !(/_or_(#{klass.column_names.join("|")}|#{klass.association_names.join("|")}#{'|'+ named_scopes unless named_scopes.empty?})/ =~ method_name).nil? 
            end

        end
      end
    end
  end
end