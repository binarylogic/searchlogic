module Searchlogic
  class Search
    module Conditions
      # Returns a hash of the current conditions set.
      def conditions
        mass_conditions.clone.merge(@conditions)
      end

      def compact_conditions
        Hash[conditions.select { |k,v| !v.blank? }]
      end

      # Accepts a hash of conditions.
      def conditions=(values)
        values.each do |condition, value|
          mass_conditions[condition.to_sym] = value
          value.delete_if { |v| ignore_value?(v) } if value.is_a?(Array)
          next if ignore_value?(value)
          send("#{condition}=", value)
        end
      end

      # Delete a condition from the search. Since conditions map to named scopes,
      # if a named scope accepts a parameter there is no way to actually delete
      # the scope if you do not want it anymore. A nil value might be meaningful
      # to that scope.
      def delete(*names)
        names.each do |name|
          @conditions.delete(name.to_sym)
          mass_conditions.delete(name)
        end
        self
      end

      private
        # This is here as a hook to allow people to modify the order in which the conditions are called, for whatever reason.
        def conditions_array
          @conditions.to_a
        end

        def write_condition(name, value)
          @conditions[name] = value
        end

        def read_condition(name)
          @conditions[name]
        end

        def mass_conditions
          @mass_conditions ||= {}
        end

        def ignore_value?(value)
          (value.is_a?(String) && value.blank?) || (value.is_a?(Array) && value.empty?)
        end
    end
  end
end