Dir[File.dirname(__FILE__) + '/or/*.rb'].each { |f| require(f) }

module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Or < Condition
          attr_reader :joins_values, :where_values
          def initialize(*args)
            super
            @joins_values ||= []
            @where_values ||= []
          end

          def scope
            if applicable?
              methods_array = MethodConstructor.new(method_name).methods_array
              methods_array.each do |m|
                __send___and_store(m)
              end
              !joins_values.flatten.empty? ? klass.includes(joins_values.flatten).where(where_values.flatten.join(" OR ")) : klass.where(where_values.flatten.join(" OR "))
            end
          end
            def self.matcher
              nil
            end
          private

          def __send___and_store(m)
            scope_key = ScopeReflection.scope_name(m)              
            if no_arg_scope?(scope_key)
              scope = klass.__send__(m)
              store_values(scope)
            else
              [value].flatten.size == 1 ? scope = klass.__send__(m, value) : scope = klass.__send__(m, *value)                
            end            
            store_values(scope)
          end

          def no_arg_scope?(scope_key)
            !!(ScopeReflection.all_named_scopes_hash[scope_key].try(:[], :scope).try(:arity) == 0)
          end

          def store_values(scope)
            joins_values << scope.joins_values
            wv = scope.where_values
            combined_values = wv.count > 1 ? wv.join(" AND ") : wv 
            where_values << combined_values
          end

          def value
            [args].flatten.size == 1 ? args.first : args
          end      


            def find_condition
              klass.joined_condition_klasses.split("|").find{ |jck| last_method.include?(jck)}
            end

            def applicable? 
              return nil if /(find_or_)/ =~ method_name 
              named_scopes = klass.named_scopes.keys.map(&:to_s).join("|")
              !(/_or_(#{klass.column_names.join("|")}|#{klass.association_names.join("|")}#{'|'+ named_scopes unless named_scopes.empty?})/ =~ method_name).nil? 
            end
        end
      end
    end
  end
end