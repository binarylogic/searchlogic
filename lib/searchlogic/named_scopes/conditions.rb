module Searchlogic
  module NamedScopes
    module Conditions
      CONDITIONS = {
        :equals => [:is, :eq],
        :does_not_equal => [:not_equal_to, :is_not, :not, :ne],
        :less_than => [:lt, :before],
        :less_than_or_equal_to => [:lte],
        :greater_than => [:gt, :after],
        :greater_than_or_equal_to => [:gte],
        :like => [:contains, :includes],
        :begins_with => [:bw],
        :ends_with => [:ew],
        :null => [:nil],
        :empty => []
      }
      PRIMARY_CONDITIONS = CONDITIONS.keys
      ALIAS_CONDITIONS = CONDITIONS.values.flatten
      
      def primary_condition(alias_condition)
        CONDITIONS.find { |k, v| k == alias_condition.to_sym || v.include?(alias_condition.to_sym) }.first
      end
      
      def condition?(name)
        primary_condition?(name) || alias_condition?(name)
      end
      
      def primary_condition?(name)
        !primary_condition_details(name).nil?
      end
      
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
          if name.to_s =~ /(\w+)_(#{PRIMARY_CONDITIONS.join("|")})$/
            {:column => $1, :condition => $2}
          end
        end
        
        def create_primary_condition(column, condition)
          scope = case condition.to_sym
          when :equals
            lambda { |value| { :conditions => { column => value } } }
          when :does_not_equal
            lambda { |value| { :conditions => { column => value } } }
          when :less_than
            lambda { |value| { :conditions => ["#{table_name}.#{column} < ?", value] } }
          when:less_than_or_equal_to
            lambda { |value| { :conditions => ["#{table_name}.#{column} <= ?", value] } }
          when :greater_than
            lambda { |value| { :conditions => ["#{table_name}.#{column} > ?", value] } }
          when :greater_than_or_equal_to
            lambda { |value| { :conditions => ["#{table_name}.#{column} >= ?", value] } }
          when :like
            lambda { |value| { :conditions => ["#{table_name}.#{column} LIKE ?", "%#{value}%"] } }
          when :begins_with
            lambda { |value| { :conditions => ["#{table_name}.#{column} LIKE ?", "#{value}%"] } }
          when :ends_with
            lambda { |value| { :conditions => ["#{table_name}.#{column} LIKE ?", "%#{value}"] } }
          when :null
            { :conditions => "#{table_name}.#{column} IS NULL" }
          when :empty
            { :conditions => "#{table_name}.#{column} = ''" }
          end
          
          named_scope("#{column}_#{condition}".to_sym, scope)
        end
        
        def alias_condition_details(name)
          if name.to_s =~ /(\w+)_(#{ALIAS_CONDITIONS.join("|")})$/
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

ActiveRecord::Base.extend(Searchlogic::NamedScopes::Conditions)
