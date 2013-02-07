module Searchlogic
  module Conditions
    class Joins < Condition

      ##Send last class the method, value save the "where values"
      ## Save where values of prev statement
      ##Join next class over with last class
      def scope
        if applicable?
          klass_in_method = match_associated_model_and_method[1]
          join_klass = klass_in_method.singularize.camelize.constantize
          method = match_associated_model_and_method[2]
          associated_models = join_klass.reflect_on_all_associations.map { |a| a.name }

          re = /(^#{associated_models.join("|")})_(.*)/
          association_in_method = re.match(method)
          if association_in_method 
            join_klass = klass.joins(klass_in_method.to_sym)
            scope = join_klass.send(method, value)
          else
            values = join_klass.send(method, value).where_values.first
            klass.joins(klass_in_method.to_sym).where(values).uniq
          end

          
        end
      end

      private
        def value
          args.first
        end
        def applicable?
          !( match_associated_model_and_method).nil?
        end
        def match_associated_model_and_method
            associated_models = klass.reflect_on_all_associations.map { |a| a.name }
            /(^#{associated_models.join("|")})_(.*)/.match(method_name)
        end
    end
  end
end