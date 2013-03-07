module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Any < Condition
          def scope
            if applicable?
              where_values = value.map{|arg| klass.send(new_method, arg).where_values}
              joined_scopes = separate_scopes(where_values)
              klass.where(joined_scopes)
            end
          end
            def self.matcher
              "_any"
            end
          private
            def new_method
              /(.*)_any/.match(method_name)[1]
            end

            def chained_method
              value.map{|arg| new_method + "#{arg}" + "_or_"}.join
            end

            def value
              args.flatten
            end

            def separate_scopes(where_values)
              or_values = where_values.map { |wv| wv.last }.join(" OR ")              
              and_values = where_values.map { |wv| next if wv.size ==1; wv.take_while{|e| e != wv.last } }.compact
              and_values.empty? ? or_values : or_values + " AND " + and_values.join(" AND ")
            end
            
            def applicable? 
              !(/(#{klass.column_names.join("|")})_.*#{self.class.matcher}$/ =~ method_name).nil?
            end

        end
      end
    end
  end
end

