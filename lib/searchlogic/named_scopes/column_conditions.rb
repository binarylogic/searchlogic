module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for columns. It allows you to do things like:
    #
    #   User.first_name_like("ben")
    #   User.id_lt(10)
    #
    # Notice the constants in this class, they define which conditions Searchlogic provides.
    #
    # See the README for a more detailed explanation.
    module ColumnConditions
      COMPARISON_CONDITIONS = {
        :equals => [:is, :eq],
        :does_not_equal => [:not_equal_to, :is_not, :not, :ne],
        :less_than => [:lt, :before],
        :less_than_or_equal_to => [:lte],
        :greater_than => [:gt, :after],
        :greater_than_or_equal_to => [:gte],
      }

      WILDCARD_CONDITIONS = {
        :like => [:contains, :includes],
        :not_like => [:does_not_include],
        :begins_with => [:bw],
        :not_begin_with => [:does_not_begin_with],
        :ends_with => [:ew],
        :not_end_with => [:does_not_end_with]
      }

      BOOLEAN_CONDITIONS = {
        :null => [:nil],
        :not_null => [:not_nil],
        :empty => [],
        :blank => [],
        :not_blank => [:present]
      }

      CONDITIONS = {}

      # Add any / all variations to every comparison and wildcard condition
      COMPARISON_CONDITIONS.merge(WILDCARD_CONDITIONS).each do |condition, aliases|
        CONDITIONS[condition] = aliases
        CONDITIONS["#{condition}_any".to_sym] = aliases.collect { |a| "#{a}_any".to_sym }
        CONDITIONS["#{condition}_all".to_sym] = aliases.collect { |a| "#{a}_all".to_sym }
      end

      CONDITIONS[:equals_any] = CONDITIONS[:equals_any] + [:in]
      CONDITIONS[:does_not_equal_all] = CONDITIONS[:does_not_equal_all] + [:not_in]

      BOOLEAN_CONDITIONS.each { |condition, aliases| CONDITIONS[condition] = aliases }

      PRIMARY_CONDITIONS = CONDITIONS.keys
      ALIAS_CONDITIONS = CONDITIONS.values.flatten

      # Is the name of the method a valid condition that can be dynamically created?
      def condition?(name)
        super || column_condition?(name)
      end

      # We want to return true for any conditions that can be called, and while we're at it. We might as well
      # create the condition so we don't have to do it again.
      def respond_to?(*args)
        super || (self != ::ActiveRecord::Base && !self.abstract_class? && !create_condition(args.first).blank?)
      end

      private
        def column_condition?(name)
          return false if name.blank?
          !condition_details(name).nil? || boolean_condition?(name)
        end

        def boolean_condition?(name)
          column = columns_hash[name.to_s] || columns_hash[name.to_s.gsub(/^not_/, "")]
          column && column.type == :boolean
        end

        def method_missing(name, *args, &block)
          if create_condition(name)
            send(name, *args, &block)
          else
            super
          end
        end

        def condition_details(method_name)
          column_name_matcher = column_names.join("|")
          conditions_matcher = (PRIMARY_CONDITIONS + ALIAS_CONDITIONS).join("|")

          if method_name.to_s =~ /^(#{column_name_matcher})_(#{conditions_matcher})$/
            {:column => $1, :condition => $2}
          end
        end

        def create_condition(name)
          @conditions_already_tried ||= []
          return nil if @conditions_already_tried.include?(name.to_s)
          @conditions_already_tried << name.to_s

          if details = condition_details(name)
            if PRIMARY_CONDITIONS.include?(details[:condition].to_sym)
              create_primary_condition(details[:column], details[:condition])
            elsif ALIAS_CONDITIONS.include?(details[:condition].to_sym)
              create_alias_condition(details[:column], details[:condition])
            end

          elsif boolean_condition?(name)
            column = name.to_s.gsub(/^not_/, "")
            named_scope name, :conditions => {column => (name.to_s =~ /^not_/).nil?}
          end
        end

        def create_primary_condition(column_name, condition)
          column = columns_hash[column_name.to_s]
          column_type = column.type
          skip_conversion = skip_time_zone_conversion_for_attributes.include?(column.name.to_sym)
          match_keyword = self.connection.adapter_name == "PostgreSQL" ? "ILIKE" : "LIKE"

          scope_options = case condition.to_s
          when /^equals/
            scope_options(condition, column, "#{table_name}.#{column.name} = ?", :skip_conversion => skip_conversion)
          when /^does_not_equal/
            scope_options(condition, column, "#{table_name}.#{column.name} != ?", :skip_conversion => skip_conversion)
          when /^less_than_or_equal_to/
            scope_options(condition, column, "#{table_name}.#{column.name} <= ?", :skip_conversion => skip_conversion)
          when /^less_than/
            scope_options(condition, column, "#{table_name}.#{column.name} < ?", :skip_conversion => skip_conversion)
          when /^greater_than_or_equal_to/
            scope_options(condition, column, "#{table_name}.#{column.name} >= ?", :skip_conversion => skip_conversion)
          when /^greater_than/
            scope_options(condition, column, "#{table_name}.#{column.name} > ?", :skip_conversion => skip_conversion)
          when /^like/
            scope_options(condition, column, "#{table_name}.#{column.name} #{match_keyword} ?", :skip_conversion => skip_conversion, :value_modifier => :like)
          when /^not_like/
            scope_options(condition, column, "#{table_name}.#{column.name} NOT #{match_keyword} ?", :skip_conversion => skip_conversion, :value_modifier => :like)
          when /^begins_with/
            scope_options(condition, column, "#{table_name}.#{column.name} #{match_keyword} ?", :skip_conversion => skip_conversion, :value_modifier => :begins_with)
          when /^not_begin_with/
            scope_options(condition, column, "#{table_name}.#{column.name} NOT #{match_keyword} ?", :skip_conversion => skip_conversion, :value_modifier => :begins_with)
          when /^ends_with/
            scope_options(condition, column, "#{table_name}.#{column.name} #{match_keyword} ?", :skip_conversion => skip_conversion, :value_modifier => :ends_with)
          when /^not_end_with/
            scope_options(condition, column, "#{table_name}.#{column.name} NOT #{match_keyword} ?", :skip_conversion => skip_conversion, :value_modifier => :ends_with)
          when "null"
            {:conditions => "#{table_name}.#{column.name} IS NULL"}
          when "not_null"
            {:conditions => "#{table_name}.#{column.name} IS NOT NULL"}
          when "empty"
            {:conditions => "#{table_name}.#{column.name} = ''"}
          when "blank"
            {:conditions => "#{table_name}.#{column.name} = '' OR #{table_name}.#{column.name} IS NULL"}
          when "not_blank"
            {:conditions => "#{table_name}.#{column.name} != '' AND #{table_name}.#{column.name} IS NOT NULL"}
          end

          named_scope("#{column.name}_#{condition}".to_sym, scope_options)
        end

        # This method helps cut down on defining scope options for conditions that allow *_any or *_all conditions.
        # Kepp in mind that the lambdas get cached in a method, so you want to keep the contents of the lambdas as
        # fast as possible, which is why I didn't do the case statement inside of the lambda.
        def scope_options(condition, column, sql, options = {})
          equals = !(condition.to_s =~ /^equals/).nil?
          does_not_equal = !(condition.to_s =~ /^does_not_equal/).nil?

          case condition.to_s
          when /_(any|all)$/
            any = $1 == "any"
            join_word = any ? " OR " : " AND "
            searchlogic_lambda(column.type, :skip_conversion => options[:skip_conversion]) { |*values|
              unless values.empty?
                if equals && any
                  has_nil = values.include?(nil)
                  values = values.flatten.compact
                  sql = attribute_condition("#{table_name}.#{column.name}", values)
                  subs = [values]

                  if has_nil
                    sql += " OR " + attribute_condition("#{table_name}.#{column.name}", nil)
                    subs << nil
                  end

                  {:conditions => [sql, *subs]}
                else
                  values.flatten!
                  values.collect! { |value| value_with_modifier(value, options[:value_modifier]) }

                  scope_sql = values.collect { |value| sql }.join(join_word)

                  {:conditions => [scope_sql, *values]}
                end
              else
                {}
              end
            }
          else
            searchlogic_lambda(column.type, :skip_conversion => options[:skip_conversion]) { |*values|
              values.collect! { |value| value_with_modifier(value, options[:value_modifier]) }

              new_sql = if does_not_equal && values == [nil]
                sql.gsub('!=', 'IS NOT')
              elsif equals && values == [nil]
                sql.gsub('=', 'IS')
              else
                sql
              end

              {:conditions => [new_sql, *values]}
            }
          end
        end

        def value_with_modifier(value, modifier)
          case modifier
          when :like
            "%#{value}%"
          when :begins_with
            "#{value}%"
          when :ends_with
            "%#{value}"
          else
            value
          end
        end

        def create_alias_condition(column_name, condition)
          primary_condition = primary_condition(condition)
          alias_name = "#{column_name}_#{condition}"
          primary_name = "#{column_name}_#{primary_condition}"
          if respond_to?(primary_name)
            (class << self; self; end).class_eval { alias_method alias_name, primary_name }
          end
        end

        # Returns the primary condition for the given alias. Ex:
        #
        #   primary_condition(:gt) => :greater_than
        def primary_condition(alias_condition)
          CONDITIONS.find { |k, v| k == alias_condition.to_sym || v.include?(alias_condition.to_sym) }.first
        end

        # Returns the primary name for any condition on a column. You can pass it
        # a primary condition, alias condition, etc, and it will return the proper
        # primary condition name. This helps simply logic throughout Searchlogic. Ex:
        #
        #   condition_scope_name(:id_gt) => :id_greater_than
        #   condition_scope_name(:id_greater_than) => :id_greater_than
        def condition_scope_name(name)
          if details = condition_details(name)
            if PRIMARY_CONDITIONS.include?(name.to_sym)
              name
            else
              "#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
            end
          else
            nil
          end
        end
    end
  end
end
