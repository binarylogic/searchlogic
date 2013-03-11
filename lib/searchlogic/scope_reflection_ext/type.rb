module Searchlogic
  module ScopeReflectionExt
    module Type
      BOOLEAN_MATCHER = [
        :null,
        :present,
        :nil,
        :blank,
      ]
      def name
        column_names = klass.column_names.sort_by(&:size).reverse
        column_names.find{|cn| method.to_s.include?(cn.to_s)}
      end

      def type
        if self.class.named_scope?(method)
          scope_name = ScopeReflection.scope_name(method)
          self.class.all_named_scopes_hash[scope_name][:type]
        elsif boolean_matcher?
          :boolean
        elsif association_method = klass.association_in_method(method)
          column_type_in_association(association_method)
        elsif column = klass.columns.detect{ |kc| /#{kc.name}_/ =~ method  }

          column.type
        else
          raise NoMethodError.new(method.to_s + " is not a defined column or scope on #{klass.to_s}")
        end
      end

      private 

      def boolean_matcher?
        !!(BOOLEAN_MATCHER.detect{|k| /#{k}$/ =~ method})
      end

      def column_type_in_association(association_method)
        association, new_method = association_method

        new_klass = association.singularize.camelize.constantize
        #Since find returns the first  match, columns sorted by largest name so
        #more specicific names get matched first e.g. "username" matches itself before "user" incorrectly does
        columns = new_klass.columns.sort{|c1, c2| c2.name.size <=> c1.name.size } if new_klass.columns.kind_of?(Array) && new_klass.columns.size >1 
        column = columns.find{|kc| new_method.to_s.include?(kc.name.to_s)}
        ass_method = new_klass.association_in_method(new_method)
        column ? column.type : column_type_in_association(ass_method)
      end
    end
  end
end