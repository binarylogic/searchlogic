module Searchlogic
  module SearchExt
    module Base
      def initialize(klass, conditions)
        @klass = klass
        self.conditions = conditions
      end

      def clone
        self.class.new(klass, conditions)
      end

      def klass
        @klass
      end

      private
        def column_name?(scope)
          !!(klass.column_names.detect{|kcn| kcn == scope.to_s})
        end    

        def delete_empty_strings(value)
          empty_strings_removed = []
          value.each do |v|
            if v.kind_of?(String)
              empty_strings_removed << v unless v.empty?
            else
              empty_strings_removed << v
            end
          end
          empty_strings_removed
        end
    end
  end
end
