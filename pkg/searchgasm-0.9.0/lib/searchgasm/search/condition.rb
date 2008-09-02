module BinaryLogic
  module Searchgasm
    module Search
      class Condition
        include Utilities
        
        BLACKLISTED_WORDS = ('a'..'z').to_a + ["about", "an", "are", "as", "at", "be", "by", "com", "de", "en", "for", "from", "how", "in", "is", "it", "la", "of", "on", "or", "that", "the", "the", "this", "to", "und", "was", "what", "when", "where", "who", "will", "with", "www"] # from ranks.nl        
        attr_accessor :column, :condition, :name, :klass
        attr_reader :value
        
        class << self
          def generate_name(column, condition)
            name_parts = []
            name_parts << (column.is_a?(String) ? column : column.name) unless column.blank?
            name_parts << condition unless condition.blank?
            name_parts.join("_")
          end
        end
        
        def initialize(condition, klass, column = nil)
          raise(ArgumentError, "#{klass.name} must acts_as_tree to use the :#{condition} condition") if requires_tree?(condition) && !has_tree?(klass)
          
          self.condition = condition
          self.name = self.class.generate_name(column, condition)
          self.klass = klass
          self.column = column.is_a?(String) ? klass.columns_hash[column] : column
        end
        
        def explicitly_set_value=(value)
          @explicitly_set_value = value
        end
        
        # Need this if someone wants to actually use nil in a meaningful way
        def explicitly_set_value?
          @explicitly_set_value == true
        end
        
        def has_tree?(klass = klass)
          !klass.reflect_on_association(:parent).nil?
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
        
        def requires_tree?(condition = condition)
          [:child_of, :sibling_of, :descendent_of, :inclusive_descendent_of].include?(condition)
        end
        
        def sanitize
          return unless explicitly_set_value?
          v = value
          v = v.utc if false && [:time, :timestamp, :datetime].include?(column.type) && klass.time_zone_aware_attributes && !klass.skip_time_zone_conversion_for_attributes.include?(column.name.to_sym)
          generate_conditions(condition, v)
        end
        
        def table_name
          klass.connection.quote_table_name(klass.table_name)
        end
        
        def value
          @value.is_a?(String) ? column.type_cast(@value) : @value
        end
        
        def value=(v)
          return if ignore_blanks? && v.blank?
          self.explicitly_set_value = true
          @value = v
        end
        
        private
          def generate_conditions(condition, value)
            if [:equals, :does_not_equal].include?(condition)
              # Let ActiveRecord handle this
              sql = klass.send(:sanitize_sql_hash_for_conditions, {column.name => value})
              if condition == :does_not_equal
                sql.gsub!(/ IS /, " IS NOT ")
                sql.gsub!(/ BETWEEN /, " NOT BETWEEN ")
                sql.gsub!(/ IN /, " NOT IN ")
                sql.gsub!(/=/, "!=")
              end
              return [sql]
            end
            
            strs = []
            subs = []
            
            if value.is_a?(Array)
              merge_conditions(*value.collect { |v| generate_conditions(condition, v) })
            else
              case condition
              when :begins_with
                search_parts = value.split(/ /)
                search_parts.each do |search_part|
                  strs << "#{table_name}.#{quoted_column_name} LIKE ?"
                  subs << "#{search_part}%"
                end
              when :contains
                strs << "#{table_name}.#{quoted_column_name} LIKE ?"
                subs << "%#{value}%"
              when :ends_with
                search_parts = value.split(/ /)
                search_parts.each do |search_part|
                  strs << "#{table_name}.#{quoted_column_name} LIKE ?"
                  subs << "%#{search_part}"
                end
              when :greater_than
                strs << "#{table_name}.#{quoted_column_name} > ?"
                subs << value
              when :greater_than_or_equal_to
                strs << "#{table_name}.#{quoted_column_name} >= ?"
                subs << value
              when :keywords
                search_parts = value.gsub(/,/, " ").split(/ /).collect { |word| word.downcase.gsub(/[^[:alnum:]]/, ''); }.uniq.select { |word| !BLACKLISTED_WORDS.include?(word.downcase) && !word.blank? }
                search_parts.each do |search_part|
                  strs << "#{table_name}.#{quoted_column_name} LIKE ?"
                  subs << "%#{search_part}%"
                end
              when :less_than
                strs << "#{table_name}.#{quoted_column_name} < ?"
                subs << value
              when :less_than_or_equal_to
                strs << "#{table_name}.#{quoted_column_name} <= ?"
                subs << value
              when :child_of
                parent_association = klass.reflect_on_association(:parent)
                foreign_key_name = (parent_association && parent_association.options[:foreign_key]) || "parent_id"
                strs << "#{table_name}.#{quote_column_name(foreign_key_name)} = ?"
                subs << value
              when :sibling_of
                parent_association = klass.reflect_on_association(:parent)
                foreign_key_name = (parent_association && parent_association.options[:foreign_key]) || "parent_id"
                parent_id = klass.find(value).send(foreign_key_name)
                return generate_conditions(:child_of, parent_id)
              when :descendent_of
                # Wish I knew how to do this in SQL
                root = klass.find(value) rescue return
                condition_strs = []
                all_children_ids(root).each do |child_id|
                  condition_strs << "#{table_name}.#{quote_column_name(klass.primary_key)} = ?"
                  subs << child_id
                end
                strs << condition_strs.join(" OR ")
              when :inclusive_descendent_of
                return merge_conditions(["#{table_name}.#{quote_column_name(klass.primary_key)} = ?", value], generate_conditions(:descendent_of, value), :any => true)
              end
            
              [strs.join(" AND "), *subs]
            end
          end
          
          def all_children_ids(record)
            ids = record.children.collect { |child| child.send(klass.primary_key) }
            record.children.each { |child| ids += all_children_ids(child) }
            ids
          end
      end
    end
  end
end