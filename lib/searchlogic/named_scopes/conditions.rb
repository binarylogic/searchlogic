module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for columns.
    module Conditions
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
        :begins_with => [:bw],
        :ends_with => [:ew],
      }
      
      BOOLEAN_CONDITIONS = {
        :null => [:nil],
        :empty => []
      }
      
      CONDITIONS = {}
      
      COMPARISON_CONDITIONS.merge(WILDCARD_CONDITIONS).each do |condition, aliases|
        CONDITIONS[condition] = aliases
        CONDITIONS["#{condition}_any".to_sym] = aliases.collect { |a| "#{a}_any".to_sym }
        CONDITIONS["#{condition}_all".to_sym] = aliases.collect { |a| "#{a}_all".to_sym }
      end
      
      BOOLEAN_CONDITIONS.each { |condition, aliases| CONDITIONS[condition] = aliases }
      
      PRIMARY_CONDITIONS = CONDITIONS.keys
      ALIAS_CONDITIONS = CONDITIONS.values.flatten
      
      # Retrieves the options passed when creating the respective named scope. Ex:
      #
      #   named_scope :whatever, :conditions => {:column => value}
      #
      # This method will return:
      #
      #   :conditions => {:column => value}
      #
      # ActiveRecord hides this internally, so we have to try and pull it out with this
      # method.
      def named_scope_options(name)
        key = scopes.key?(name.to_sym) ? name.to_sym : primary_condition_name(name)
        
        if key
          eval("options", scopes[key])
        else
          nil
        end
      end
      
      # The arity for a named scope's proc is important, because we use the arity
      # to determine if the condition should be ignored when calling the search method.
      # If the condition is false and the arity is 0, then we skip it all together. Ex:
      #
      #   User.named_scope :age_is_4, :conditions => {:age => 4}
      #   User.search(:age_is_4 => false) == User.all
      #   User.search(:age_is_4 => true) == User.all(:conditions => {:age => 4})
      #
      # We also use it when trying to "copy" the underlying named scope for association
      # conditions.
      def named_scope_arity(name)
        options = named_scope_options(name)
        options.respond_to?(:arity) ? options.arity : nil
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
      #   primary_condition_name(:id_gt) => :id_greater_than
      #   primary_condition_name(:id_greater_than) => :id_greater_than
      def primary_condition_name(name)
        if primary_condition?(name)
          name.to_sym
        elsif details = alias_condition_details(name)
          "#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
        else
          nil
        end
      end
      
      # Is the name of the method a valid condition that can be dynamically created?
      def condition?(name)
        primary_condition?(name) || alias_condition?(name)
      end
      
      # Is the name of the method a valid condition that can be dynamically created,
      # AND is it a primary condition (not an alias). "greater_than" not "gt".
      def primary_condition?(name)
        !primary_condition_details(name).nil?
      end
      
      # Is the name of the method a valid condition that can be dynamically created,
      # AND is it an alias condition. "gt" not "greater_than".
      def alias_condition?(name)
        !alias_condition_details(name).nil?
      end
      
      private
        def method_missing(name, *args, &block)
          if details = primary_condition_details(name)
            create_primary_condition(details[:column], details[:condition])
            send(name, *args)
          elsif details = alias_condition_details(name)
            create_alias_condition(details[:column], details[:condition], args)
            send(name, *args)
          else
            super
          end
        end
        
        def primary_condition_details(name)
          if name.to_s =~ /^(#{column_names.join("|")})_(#{PRIMARY_CONDITIONS.join("|")})$/
            {:column => $1, :condition => $2}
          end
        end
        
        def create_primary_condition(column, condition)
          column_type = columns_hash[column.to_s].type
          scope_options = case condition.to_s
          when /^equals/
            scope_options(condition, column_type, "#{table_name}.#{column} = ?")
          when /^does_not_equal/
            scope_options(condition, column_type, "#{table_name}.#{column} != ?")
          when /^less_than_or_equal_to/
            scope_options(condition, column_type, "#{table_name}.#{column} <= ?")
          when /^less_than/
            scope_options(condition, column_type, "#{table_name}.#{column} < ?")
          when /^greater_than_or_equal_to/
            scope_options(condition, column_type, "#{table_name}.#{column} >= ?")
          when /^greater_than/
            scope_options(condition, column_type, "#{table_name}.#{column} > ?")
          when /^like/
            scope_options(condition, column_type, "#{table_name}.#{column} LIKE ?", :like)
          when /^begins_with/
            scope_options(condition, column_type, "#{table_name}.#{column} LIKE ?", :begins_with)
          when /^ends_with/
            scope_options(condition, column_type, "#{table_name}.#{column} LIKE ?", :ends_with)
          when "null"
            {:conditions => "#{table_name}.#{column} IS NULL"}
          when "empty"
            {:conditions => "#{table_name}.#{column} = ''"}
          end
          
          named_scope("#{column}_#{condition}".to_sym, scope_options)
        end
        
        # This method helps cut down on defining scope options for conditions that allow *_any or *_all conditions.
        # Kepp in mind that the lambdas get cached in a method, so you want to keep the contents of the lambdas as
        # fast as possible, which is why I didn't do the case statement inside of the lambda.
        def scope_options(condition, column_type, sql, value_modifier = nil)
          case condition.to_s
          when /_(any|all)$/
            searchlogic_lambda(column_type) { |*values|
              return {} if values.empty?
              values = values.flatten
              
              values_to_sub = nil
              if value_modifier.nil?
                values_to_sub = values
              else
                values_to_sub = values.collect { |value| value_with_modifier(value, value_modifier) }
              end
              
              join = $1 == "any" ? " OR " : " AND "
              {:conditions => [values.collect { |value| sql }.join(join), *values_to_sub]}
            }
          else
            searchlogic_lambda(column_type) { |value| {:conditions => [sql, value_with_modifier(value, value_modifier)]} }
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
        
        def alias_condition_details(name)
          if name.to_s =~ /^(#{column_names.join("|")})_(#{ALIAS_CONDITIONS.join("|")})$/
            {:column => $1, :condition => $2}
          end
        end
        
        def create_alias_condition(column, condition, args)
          primary_condition = primary_condition(condition)
          alias_name = "#{column}_#{condition}"
          primary_name = "#{column}_#{primary_condition}"
          send(primary_name, *args) # go back to method_missing and make sure we create the method
          (class << self; self; end).class_eval { alias_method alias_name, primary_name }
        end
    end
  end
end
