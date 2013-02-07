module Searchlogic
  module Conditions
    class Joins < Condition
      def self.applicable?(name)
        check if name starts with join
      end

      def scope
        # Company.users_name_equals("ben")
        # => check: a = Company.reflect_on_all_associations.find { |a| a.name == :users }
        # => a.klass => User
        # => scope = a.klass.send("name_equals", "ben")
        # => joins(:users).joins(scope.joins_sql).where(scope.where_sql)
        join = find_join
        scope = join.klass.send("id_greater_than", 10)
        scope.to_sql
        ##User.orders_id_greater_than(10)
        ##Order.greater_than(10)
        ##User.join(:orders)

        join = @klass.joins(column_name.to_sym)
        new_method = find_class_from_method(method_name)[1]
        join.send(new_method)
      end

      private
        def value
          args.first
        end
        def find_class_from_method(method)
          /(#{column_name})_(.*)/.match(method)
        end
    end
  end
end