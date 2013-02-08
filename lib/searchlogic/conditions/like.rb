module Searchlogic
  module Conditions
    class Like < Condition
      def initialize(klass, method_name, args, &block)
        super
      end


      def scope
        if applicable?
          @or_conditions = find_columns.length == 1 ? "" : calc_or_conditions if method_name.to_s.include?("or")
          klass.where("#{table_name}.#{column_name} like ? #{or_conditions}", "%#{value}%"  )  
        end

      end

      private
        def applicable? 
          !(/(#{klass.column_names.join("|")})_like$/ =~ method_name).nil? 
        end

        def calc_or_conditions
          find_columns.map { |cn| "OR #{table_name}.#{cn} like #{value}" }[1..-1].join(" ").gsub!(value, value.split("").unshift("'%").push("%'").join) 
        end
    end
  end
end