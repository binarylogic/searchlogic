module BinaryLogic
  module Searchgasm
    module Search
      class Condition
        include Utilities
        
        BLACKLISTED_WORDS = ('a'..'z').to_a + ["about", "an", "are", "as", "at", "be", "by", "com", "de", "en", "for", "from", "how", "in", "is", "it", "la", "of", "on", "or", "that", "the", "the", "this", "to", "und", "was", "what", "when", "where", "who", "will", "with", "www"] # from ranks.nl        
        attr_accessor :column, :condition, :name, :klass
        attr_reader :value
        
        def initialize(condition, klass, column)
          self.condition = condition
          self.name = "#{column.name}_#{condition}"
          self.klass = klass
          self.column = column
        end
        
        def explicitly_set_value=(value)
          @explicitly_set_value = value
        end
        
        # Need this if someone wants to actually use nil in a meaningful way
        def explicitly_set_value?
          @explicitly_set_value == true
        end
        
        def ignore_blanks?
          ![:equals, :does_not_equal].include?(condition)
        end
        
        def quote_column_name(column_name)
          klass.connection.quote_column_name(column_name)
        end
        
        def quoted_column_name
          quote_column_name(column.name)
        end
        
        def reset!
          self.explicitly_set_value = nil
        end
        
        def sanitize(alt_value = nil)
          return unless explicitly_set_value?
          
          # We don't want to sanitize to pure sql, just sql substitues and let ActiveRecord handle the rest
          v = alt_value || value
          v = v.utc if v.respond_to?(:utc) # add check to see if they set the time zone to something besides utc, maybe they arent storing in utc?
          
          if [:equals, :does_not_equal].include?(condition)
            # Let ActiveRecord handle this
            sql = klass.send(:sanitize_sql_hash_for_conditions, {column.name => v})
            if condition == :does_not_equal
              sql.gsub!(/ IS /, " IS NOT ")
              sql.gsub!(/ BETWEEN /, " NOT BETWEEN ")
              sql.gsub!(/=/, "!=")
            end
            return [sql]
          end
            
          if v.is_a?(Array)
            merge_conditions(*v.collect { |i| sanitize(i) })
          else
            strs = []
            subs = []
                        
            case condition
            when :begins_with
              search_parts = v.split(/ /)
              search_parts.each do |search_part|
                strs << "#{table_name}.#{quoted_column_name} like ?"
                subs << "#{search_part}%"
              end
            when :contains
              strs << "#{table_name}.#{quoted_column_name} like ?"
              subs << "%#{v}%"
            when :ends_with
              search_parts = v.split(/ /)
              search_parts.each do |search_part|
                strs << "#{table_name}.#{quoted_column_name} like ?"
                subs << "%#{search_part}"
              end
            when :greater_than
              strs << "#{table_name}.#{quoted_column_name} > ?"
              subs << v
            when :greater_than_or_equal_to
              strs << "#{table_name}.#{quoted_column_name} >= ?"
              subs << v
            when :keywords
              search_parts = v.split(/ /).select { |word| !BLACKLISTED_WORDS.include?(word.downcase) }
              search_parts.each do |search_part|
                strs << "#{table_name}.#{quoted_column_name} like ?"
                subs << "%#{search_part}%"
              end
            when :less_than
              strs << "#{table_name}.#{quoted_column_name} < ?"
              subs << v
            when :less_than_or_equal_to
              strs << "#{table_name}.#{quoted_column_name} <= ?"
              subs << v
            when :descendent_of
              root = searched_class.find(v)
              condition_strs = ["#{table_name}.#{quote_column_name(primary_key)} = ?"]
              subs << v
              root.all_children.each do |child|
                condition_strs << "#{table_name}.#{quote_column_name(primary_key)} = ?"
                subs << child.send(primary_key)
              end
              strs << condition_strs.join(" or ")
            end
          
            [strs.join(" and "), *subs]
          end
        end
        
        def table_name
          klass.table_name
        end
        
        def value
          @value.is_a?(String) ? column.type_cast(@value) : @value
        end
        
        def value=(v)
          return if ignore_blanks? && v.blank?
          self.explicitly_set_value = true
          @value = v
        end
      end
    end
  end
end