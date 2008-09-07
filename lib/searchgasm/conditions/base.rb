module Searchgasm
  module Conditions # :nodoc:
    # = Conditions
    #
    # Represents a collection of conditions and performs various tasks on that collection. For information on each condition see Searchgasm::Condition.
    # Each condition has its own file and class and the source for each condition is pretty self explanatory.
    class Base
      include Utilities
      
      attr_accessor :klass, :relationship_name, :scope
      
      class << self
        # Registers a condition as an available condition for a column or a class.
        #
        # === Example
        #
        #   config/initializers/searchgasm.rb
        #   # Actual function for MySQL databases only
        #   class SoundsLike < Searchgasm::Condition::Base
        #     class << self
        #       # I pass you the column, you tell me what you want the method to be called.
        #       # If you don't want to add this condition for that column, return nil
        #       # It defaults to "#{column.name}_sounds_like". So if thats what you want you don't even need to do this.
        #       def name_for_column(column)
        #         super
        #       end
        #
        #       # Only do this if you want aliases for your condition
        #       def aliases_for_column(column)
        #         ["#{column.name}_sounds", "#{column.name}_similar_to"]
        #       end
        #     end
        #
        #     # You can return an array or a string. NOT a hash, because all of these conditions
        #     # need to eventually get merged together. The array or string can be anything you would put in
        #     # the :conditions option for ActiveRecord::Base.find()
        #     def to_conditions(value)
        #       ["#{quoted_table_name}.#{quoted_column_name} SOUNDS LIKE ?", value]
        #     end
        #   end
        #
        #   Searchgasm::Seearch::Conditions.register_condition(SoundsLikeCondition)
        def register_condition(klass)
          raise(ArgumentError, "You can only register conditions that extend Searchgasm::Condition::Base") unless klass.ancestors.include?(Searchgasm::Condition::Base)
          conditions << klass unless conditions.include?(klass)
        end
        
        # A list of available condition type classes
        def conditions
          @@conditions ||= []
        end
        
        def needed?(klass, conditions) # :nodoc:
          if conditions.is_a?(Hash)
            conditions.stringify_keys.keys.each do |condition|
              return true unless klass.column_names.include?(condition)
            end
          end
          
          false
        end
      end
      
      def initialize(klass, init_conditions = {})
        self.klass = klass
        add_klass_conditions!
        add_column_conditions!
        add_associations!
        self.conditions = init_conditions
      end
      
      # Setup methods for searching
      [:all, :average, :calculate, :count, :find, :first, :maximum, :minimum, :sum].each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            self.conditions = args.extract_options!
            args << {:conditions => sanitize}
            klass.#{method}(*args)
          end
        end_eval
      end
      
      # A list of includes to use when searching, includes relationships
      def includes
        i = []
        associations.each do |association|
          association_includes = association.includes
          i << (association_includes.blank? ? association.relationship_name.to_sym : {association.relationship_name.to_sym => association_includes})
        end
        i.blank? ? nil : (i.size == 1 ? i.first : i)
      end
      
      # Sanitizes the conditions down into conditions that ActiveRecord::Base.find can understand.
      def sanitize
        conditions = merge_conditions(*objects.collect { |object| object.sanitize })
        return scope if conditions.blank?
        merge_conditions(conditions, scope)
      end
      
      # Allows you to set the conditions via a hash. If you do not pass a hash it will set scope instead, so that you can continue to add conditions and ultimately
      # merge it all together at the end.
      def conditions=(conditions)
        case conditions
        when Hash
          assert_valid_conditions(conditions)
          remove_conditions_from_protected_assignement(conditions).each { |condition, value| send("#{condition}=", value) }
        else
          self.scope = conditions
        end
      end
      
      # All of the active conditions (conditions that have been set)
      def conditions
        conditions_hash = {}
        objects.each do |object|
          case object
          when self.class
            relationship_conditions = object.conditions
            next if relationship_conditions.blank?
            conditions_hash[object.relationship_name.to_sym] = relationship_conditions
          else
            next unless object.explicitly_set_value?
            conditions_hash[object.name.to_sym] = object.value
          end
        end
        conditions_hash
      end
      
      private
        def add_associations!
          klass.reflect_on_all_associations.each do |association|
            self.class.class_eval <<-"end_eval", __FILE__, __LINE__
              def #{association.name}
                if @#{association.name}.nil?
                  @#{association.name} = self.class.new(#{association.class_name})
                  @#{association.name}.relationship_name = "#{association.name}"
                  objects << @#{association.name}
                end
                @#{association.name}
              end
            
              def #{association.name}=(conditions); #{association.name}.conditions = conditions; end
              def reset_#{association.name}!; objects.delete(#{association.name}); @#{association.name} = nil; end
            end_eval
          end
        end
        
        def add_column_conditions!
          klass.columns.each do |column|
            self.class.conditions.each do |condition_klass|
              name = condition_klass.name_for_column(column)
              next if name.blank?
              add_condition!(condition_klass, name, column)
              condition_klass.aliases_for_column(column).each { |alias_name| add_condition_alias!(alias_name, name) }
            end
          end
        end
        
        def add_condition!(condition, name, column = nil)
          condition_names << name
          self.class.class_eval <<-"end_eval", __FILE__, __LINE__
            def #{name}_object
              if @#{name}.nil?
                @#{name} = #{condition.name}.new(klass#{column.nil? ? "" : ", \"#{column.name}\""})
                objects << @#{name}
              end
              @#{name}
            end

            def #{name}; #{name}_object.value; end
            def #{name}=(value); #{name}_object.value = value; end
            def reset_#{name}!; objects.delete(#{name}_object); @#{name} = nil; end
          end_eval
        end
        
        def add_condition_alias!(alias_name, name)
          condition_names << alias_name
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
        
        def assert_valid_conditions(conditions)
          keys = condition_names.collect { |condition_name| condition_name.to_sym }
          keys += klass.reflect_on_all_associations.collect { |association| association.name }
          conditions.symbolize_keys.assert_valid_keys(keys)
        end
        
        def associations
          objects.select { |object| object.is_a?(self.class) }
        end
        
        def condition_names
          @condition_names ||= []
        end
        
        def objects
          @objects ||= []
        end
        
        def remove_conditions_from_protected_assignement(conditions)
          return conditions if klass.accessible_conditions.nil? && klass.protected_conditions.nil?
          if klass.accessible_conditions
            conditions.reject { |condition, value| !klass.accessible_conditions.include?(condition.to_s) }
          elsif klass.protected_conditions
            conditions.reject { |condition, value| klass.protected_conditions.include?(condition.to_s) }
          end
        end
    end
  end
end