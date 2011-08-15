module Searchlogic
  class Search
    module MethodMissing
      def respond_to?(*args)
        super || scope?(normalize_scope_name(args.first))
      rescue Searchlogic::NamedScopes::OrConditions::UnknownConditionError
        false
      end

      private
        def method_missing(name, *args, &block)
          condition_name = condition_name(name)
          scope_name = scope_name(condition_name)

          if setter?(name)
            if scope?(scope_name)
              if args.size == 1
                write_condition(
                  condition_name,
                  type_cast(
                    args.first,
                    cast_type(scope_name),
                    scope_options(scope_name).respond_to?(:searchlogic_options) ? scope_options(scope_name).searchlogic_options : {}
                  )
                )
              else
                write_condition(condition_name, args)
              end
            else
              raise UnknownConditionError.new(condition_name)
            end
          elsif scope?(scope_name) && args.size <= 1
            if args.size == 0
              read_condition(condition_name)
            else
              send("#{condition_name}=", *args)
              self
            end
          else
            scope = conditions_array.inject(klass.scoped(current_scope) || {}) do |scope, condition|
              scope_name, value = condition
              scope_name = normalize_scope_name(scope_name)
              klass.send(scope_name, value) if !klass.respond_to?(scope_name)
              arity = klass.named_scope_arity(scope_name)

              if !arity || arity == 0
                if value == true
                  scope.send(scope_name)
                else
                  scope
                end
              elsif arity == -1
                scope.send(scope_name, *(value.is_a?(Array) ? value : [value]))
              else
                scope.send(scope_name, value)
              end
            end
            scope.send(name, *args, &block)
          end
        end

        def normalize_scope_name(scope_name)
          case
          when klass.scopes.key?(scope_name.to_sym) then scope_name.to_sym
          when klass.column_names.include?(scope_name.to_s) then "#{scope_name}_equals".to_sym
          else scope_name.to_sym
          end
        end

        def setter?(name)
          !(name.to_s =~ /=$/).nil?
        end

        def condition_name(name)
          condition = name.to_s.match(/(\w+)=?$/)
          condition ? condition[1].to_sym : nil
        end

        def cast_type(name)
          named_scope_options = scope_options(name)
          arity = klass.named_scope_arity(name)
          if !arity || arity == 0
            :boolean
          else
            named_scope_options.respond_to?(:searchlogic_options) ? named_scope_options.searchlogic_options[:type] : :string
          end
        end

        def type_cast(value, type, options = {})
          case value
          when Array
            value.collect { |v| type_cast(v, type) }
          when Range
            Range.new(type_cast(value.first, type), type_cast(value.last, type))
          else
            # Let's leverage ActiveRecord's type casting, so that casting is consistent
            # with the other models.
            column_for_type_cast = ::ActiveRecord::ConnectionAdapters::Column.new("", nil)
            column_for_type_cast.instance_variable_set(:@type, type)
            casted_value = column_for_type_cast.type_cast(value)

            if Time.zone && casted_value.is_a?(Time)
              if value.is_a?(String)
                # if its a string, we should assume the user means the local time
                # we need to update the object to include the proper time zone without changing
                # the time
                (casted_value + (Time.zone.utc_offset * -1)).in_time_zone(Time.zone)
              else
                casted_value.in_time_zone
              end
            else
              casted_value
            end
          end
        end
    end
  end
end