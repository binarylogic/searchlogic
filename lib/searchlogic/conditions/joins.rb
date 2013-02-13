module Searchlogic
  module Conditions
    class Joins < Condition
      DELIMITER = "__"
      def scope
        return nil unless applicable?
        method = method_name.to_s.split(DELIMITER)
        # join_name = method.shift.to_sym
        # join = klass.joins(join_name)
        associations = []
        method.each_with_index  do | m , i |
          kass = m.singularize.camelize.constantize
          kass.reflect_on_all_associations.map{ |a| a.name.to_s }

          associations << klass.reflect_on_all_associations.find { |association| association.name == method[i + 1].pluralize.downcase.to_sym }
          binding.pry
        end
        binding.pry
        association = klass.reflect_on_all_associations.find { |association| association.name == join_name }
        ass = klass.reflect_on_all_associations.map(&:name)
        joins = []
        while ass.detect{|a| method.first.include?(a.to_s)} 
          joins << klass.name 
          bindng.pry
          association.klass.send(method.join(DELIMITER), value) 
        end
        binding.pry 
        if nested_scope.joins_values.empty?
          klass.joins(join_name).where(nested_scope.where_values.first).uniq
        else
          klass.joins(join_name => nested_scope.joins_values).where(nested_scope.where_values.first).uniq
        end
      end

      private
        def applicable?
          !(/#{DELIMITER}/.match(method_name).nil?)
        end
    end
  end
end