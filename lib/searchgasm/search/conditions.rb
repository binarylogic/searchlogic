module BinaryLogic
  module Searchgasm
    module Search
      class Conditions
        include Utilities
        
        attr_accessor :klass, :protect, :relationship_name, :scope
        
        class << self
          def register_condition(klass)
            raise(ArgumentError, "You can only register conditions that extend BinaryLogic::Searchgasm::Search::ConditionTypes::Condition") unless klass.ancestors.include?(Condition)
            conditions << klass unless conditions.include?(klass)
          end
          
          def conditions
            @@conditions ||= []
          end
        end
        
        def initialize(klass, init_values = {})
          self.klass = klass
          add_klass_conditions!
          add_column_conditions!
          add_associations!
          self.value = init_values
        end
        
        # Setup methods for searching
        [:all, :average, :calculate, :count, :find, :first, :maximum, :minimum, :sum].each do |method|
          class_eval <<-end_eval
            def #{method}(*args)
              self.value = args.extract_options!
              args << {:conditions => sanitize}
              klass.#{method}(*args)
            end
          end_eval
        end
        
        def assert_valid_values(values)
          keys = condition_names.collect { |condition_name| condition_name.to_sym }
          keys += klass.reflect_on_all_associations.collect { |association| association.name }
          values.symbolize_keys.assert_valid_keys(keys)
        end
        
        def associations
          objects.select { |object| object.is_a?(self.class) }
        end
        
        def condition_names
          @condition_names ||= []
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
        
        def protect?
          protect == true
        end
        
        def sanitize
          conditions = merge_conditions(*objects.collect { |object| object.sanitize })
          return scope if conditions.blank?
          merge_conditions(conditions, scope)
        end
        
        def value=(values)
          case values
          when Hash
            assert_valid_values(values)
            values.each { |condition, value| send("#{condition}=", value) }
          else
            raise(ArgumentError, "You can not set a scope or pass SQL while the search is being protected") if protect?
            self.scope = values
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
          def add_associations!
            klass.reflect_on_all_associations.each do |association|
              self.class.class_eval <<-end_eval
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
              end_eval
            end
          end
          
          def add_column_conditions!
            klass.columns.each do |column|
              self.class.conditions.each do |condition|
                name = condition.name_for_column(column)
                next if name.blank?
                add_condition!(condition, name, column)
                condition.aliases_for_column(column).each { |alias_name| add_condition_alias!(alias_name, name) }
              end
            end
          end
          
          def add_condition!(condition, name, column = nil)
            self.condition_names << name
            self.class.class_eval <<-end_eval
              def #{name}_object
                if @#{name}.nil?
                  @#{name} = #{condition.name}.new(klass#{column.nil? ? "" : ", \"#{column.name}\""})
                  self.objects << @#{name}
                end
                @#{name}
              end

              def #{name}; #{name}_object.value; end
              def #{name}=(value); #{name}_object.value = value; end
              def reset_#{name}!; objects.delete(#{name}_object); @#{name} = nil; end
            end_eval
          end
          
          def add_condition_alias!(alias_name, name)
            self.condition_names << alias_name
            self.class.class_eval do
              alias_method alias_name, name
              alias_method "#{alias_name}=", "#{name}="
            end
          end
          
          def add_klass_conditions!
            self.class.conditions.each do |condition|
              name = condition.name_for_klass(klass)
              next if name.blank?
              add_condition!(condition, name)
              condition.aliases_for_klass(klass).each { |alias_name| add_condition_alias!(alias_name, name) }
            end
          end
      end
    end
  end
end