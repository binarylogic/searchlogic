module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Joins < Condition
          attr_reader :method_parts, :join_name, :new_method, :association
          DELIMITER = "__"

          def initialize(*args)
            super
            @method_parts = method_name.to_s.split(DELIMITER) 
            @join_name = find_join_name
            method_parts.shift.to_sym
            @new_method = find_new_method
            @association = find_association
          end      

          def scope
            return nil unless applicable?
            nested_scope = created_nested_scope
            where_values = nested_scope.where_values 
            join_values = nested_scope.joins_values
            if where_values.empty?
              generate_join_and_send_method(join_values)
            else
              generate_join_with_where_values(where_values.first, join_values)
            end
          end

            def self.matcher
              nil
            end


          private
            def created_nested_scope

              args.compact!
              args.empty? ? association.klass.send(new_method) : association.klass.send(new_method, value)
            end

            def named_scopes? 
              klass.named_scopes.keys.map(&:to_s).include?(new_method.to_s)
            end

            def generate_join_and_send_method(join_values)
              klass.
                joins(join_values.any? ? {join_name => join_values.first} : join_name.to_sym).
                send(send_method)          
            end

            def generate_join_with_where_values(where_values, join_values)
              klass.
                joins(join_values.any? ? {join_name => join_values.first} : join_name.to_sym).
                where(where_values).uniq          
            end

            def applicable?
              !(/#{DELIMITER}/.match(method_name).nil?) || match_ordering
            end

            def match_ordering
              /(descend_by_|ascend_by_)(#{klass.tables.join("|")}|#{klass.tables.map(&:singularize).join("|")})/.match(method_name.to_s.split(DELIMITER).first)
            end

            def send_method
              match_ordering ? match_ordering[1] + method_parts.last : method_parts.last
            end

            def find_join_name
              match_ordering ? match_ordering[2].to_s.pluralize : method_parts.first.to_s.pluralize
            end

            def find_new_method
              match_ordering ? match_ordering[1] + method_parts.join(DELIMITER) : method_parts.join(DELIMITER) 
            end

            def find_association
              klass.reflect_on_all_associations.find { |association| association.name == join_name || association.name.to_s == join_name }
            end
        end
      end
    end
  end
end