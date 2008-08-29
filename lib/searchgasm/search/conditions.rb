module BinaryLogic
  module Searchgasm
    module Search
      class Conditions
        include Utilities
        
        attr_accessor :klass, :scope
        
        def initialize(klass, values = {})
          self.klass = klass
          klass.columns.each { |column| add_conditions_for_column!(column) }
          self.value = values
        end
        
        def objects
          @objects ||= []
        end
        
        def objects_hash
          return @objects_hash unless @objects_hash.nil?
          @objects_hash = {}
          objects.each { |object| @objects_hash[object.name.to_sym] = object }
          @objects_hash
        end
        
        def reset!
          objects.each { |object| object.reset! }
        end
        
        def sanitize
          sanitized_objects = merge_conditions(*objects.collect { |object| object.sanitize }.compact)
          return scope if sanitized_objects.blank?
          merge_conditions(sanitized_objects, scope)
        end
        
        def value=(conditions)
          reset!
          self.scope = nil
          
          case conditions
          when Hash
            conditions.each { |condition, value| send("#{condition}=", value) }
          when Array
            self.scope = conditions
          when String
            self.scope = [conditions]
          end
        end
        
        def value
          values_hash = {}
          objects.each do |object|
            next unless object.explicitly_set_value?
            values_hash[object.name] = object.value
          end
          values_hash
        end
        
        private
          def add_conditions_for_column!(column)
            condition_names = [:equals, :does_not_equal]
            case column.type
            when :string, :text
              condition_names += [:begins_with, :contains, :keywords, :ends_with]
            when :integer, :float, :decimal, :datetime, :timestamp, :time, :date
              condition_names += [:greater_than, :greater_than_or_equal_to, :less_than, :less_than_or_equal_to]
            end
            
            condition_names.collect { |condition_name| add_condition!(condition_name, column) }
          end
          
          def add_condition!(condition_name, column)
            object = Condition.new(condition_name, klass, column)
            
            self.objects ||= []
            self.objects << object
            @objects_hash = nil
            
            # Define accessor methods
            self.class.class_eval <<-SRC
              def #{object.name}; objects_hash[:#{object.name}].value; end
              def #{object.name}=(value); objects_hash[:#{object.name}].value = value; end
              def reset_#{object.name}!; objects_hash[:#{object.name}].reset!; end
            SRC
            
            # Define aliases
            alias_condition_names(object).each do |alias_condition_name|
              method_name = alias_condition_name.blank? ? column.name : "#{column.name}_#{alias_condition_name}"
              self.class.class_eval do
                alias_method method_name, object.name
                alias_method "#{method_name}=", "#{object.name}="
              end
            end
            
            object
          end
          
          def alias_condition_names(object)
            case object.condition
            when :equals                    then ["", :is]
            when :does_not_equal            then [:is_not, :not]
            when :begins_with               then [:starts_with]
            when :contains                  then [:like]
            when :greater_than              then [:gt, :after]
            when :greater_than_or_equal_to  then [:at_least, :gte]
            when :less_than                 then [:lt, :before]
            when :less_than_or_equal_to     then [:at_most, :lte]
            end
          end
      end
    end
  end
end