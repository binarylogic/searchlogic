module BinaryLogic
  module Searchgasm
    module Search
      class Conditions
        include Utilities
        
        attr_accessor :klass, :relationship_name, :scope
        
        class << self
          def conditions_for_column_type(type)
            condition_names = [:equals, :does_not_equal]
            case type
            when :string, :text
              condition_names += [:begins_with, :contains, :keywords, :ends_with]
            when :integer, :float, :decimal, :datetime, :timestamp, :time, :date
              condition_names += [:greater_than, :greater_than_or_equal_to, :less_than, :less_than_or_equal_to]
            end
            condition_names
          end
        
          def alias_conditions(condition)
            case condition
            when :equals                    then  ["", :is]
            when :does_not_equal            then  [:is_not, :not]
            when :begins_with               then  [:starts_with]
            when :contains                  then  [:like]
            when :greater_than              then  [:gt, :after]
            when :greater_than_or_equal_to  then  [:at_least, :gte]
            when :less_than                 then  [:lt, :before]
            when :less_than_or_equal_to     then  [:at_most, :lte]
            else                                  []
            end
          end
        end
        
        def initialize(klass, values = {})
          self.klass = klass
          klass.columns.each { |column| add_conditions_for_column!(column) }
          klass.reflect_on_all_associations.each { |association| add_association!(association)  }
          self.value = values
        end
        
        def associations
          objects.select { |object| object.is_a?(self.class) }
        end
        
        def includes
          i = []
          associations.each do |association|
            association_includes = association.includes
            i << (association_includes.blank? ? association.relationship_name.to_sym : {association.relationship_name.to_sym => association_includes})
          end
          i.blank? ? nil : (i.size == 1 ? i.first : i)
        end
        
        def objects
          @objects ||= []
        end
        
        def reset!
          dupped_objects = objects.dup
          dupped_objects.each do |object|
            if object.is_a?(self.class)
              send("reset_#{object.relationship_name}!")
            else
              send("reset_#{object.name}!")
            end
          end
          objects
        end
        
        def sanitize
          sanitized_objects = merge_conditions(*objects.collect { |object| object.sanitize })
          return scope if sanitized_objects.blank?
          merge_conditions(sanitized_objects, scope)
        end
        
        def value=(conditions)
          reset!
          self.scope = nil
          
          case conditions
          when Hash
            conditions.each { |condition, value| send("#{condition}=", value) }
          else
            self.scope = conditions
          end
        end
        
        def value
          values_hash = {}
          objects.each do |object|
            next unless object.explicitly_set_value?
            values_hash[object.name.to_sym] = object.value
          end
          values_hash
        end
        
        private
          def add_association!(association)
            self.class.class_eval <<-SRC
              def #{association.name}
                if @#{association.name}.nil?
                  @#{association.name} = self.class.new(#{association.class_name})
                  @#{association.name}.relationship_name = "#{association.name}"
                  self.objects << @#{association.name}
                end
                @#{association.name}
              end
              
              def #{association.name}=(value); #{association.name}.value = value; end
              def reset_#{association.name}!; objects.delete(#{association.name}); @#{association.name} = nil; end
            SRC
            
            association.name
          end
          
          def add_conditions_for_column!(column)
            self.class.conditions_for_column_type(column.type).collect { |condition_name| add_condition!(condition_name, column) }
          end
          
          def add_condition!(condition_name, column)
            name = Condition.generate_name(column, condition_name)

            # Define accessor methods
            self.class.class_eval <<-SRC
              def #{name}_object
                if @#{name}.nil?
                  @#{name} = Condition.new(:#{condition_name}, klass, "#{column.name}")
                  self.objects << @#{name}
                end
                @#{name}
              end
              
              def #{name}; #{name}_object.value; end
              def #{name}=(value); #{name}_object.value = value; end
              def reset_#{name}!; objects.delete(#{name}_object); @#{name} = nil; end
            SRC
            
            # Define aliases
            self.class.alias_conditions(condition_name).each do |alias_condition_name|
              alias_name = Condition.generate_name(column, alias_condition_name)
              self.class.class_eval do
                alias_method alias_name, name
                alias_method "#{alias_name}=", "#{name}="
              end
            end
            
            name
          end
      end
    end
  end
end