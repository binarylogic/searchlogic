module Searchgasm
  module Conditions # :nodoc:
    # = Conditions
    #
    # Represents a collection of conditions and performs various tasks on that collection. For information on each condition see Searchgasm::Condition.
    # Each condition has its own file and class and the source for each condition is pretty self explanatory.
    class Base
      include Shared::Utilities
      include Shared::VirtualClasses
      
      attr_accessor :any, :relationship_name
      
      class << self
        attr_accessor :added_klass_conditions, :added_column_conditions, :added_associations
        
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
        #       # It defaults to "#{column.name}_sounds_like" (using the class name). So if thats what you want you don't even need to do this.
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
        #     # the :conditions option for ActiveRecord::Base.find(). Also, for a list of methods / variables you can use check out earchgasm::Condition::Base
        #     def to_conditions(value)
        #       ["#{quoted_table_name}.#{quoted_column_name} SOUNDS LIKE ?", value]
        #     end
        #   end
        #
        #   Searchgasm::Seearch::Conditions.register_condition(SoundsLikeCondition)
        def register_condition(condition_class)
          raise(ArgumentError, "You can only register conditions that extend Searchgasm::Condition::Base") unless condition_class.ancestors.include?(Searchgasm::Condition::Base)
          conditions << condition_class unless conditions.include?(condition_class)
        end
        
        # A list of available condition type classes
        def conditions
          @@conditions ||= []
        end
        
        # A list of all associations created, used for caching and performance
        def association_names
          @association_names ||= []
        end
        
        # A list of all conditions available, users for caching and performance
        def condition_names
          @condition_names ||= []
        end
        
        def needed?(model_class, conditions) # :nodoc:
          return false if conditions.blank?
          
          if conditions.is_a?(Hash)
            return true if conditions[:any]
            stringified_conditions = conditions.stringify_keys
            stringified_conditions.keys.each { |condition| return false if condition.include?(".") } # setting conditions on associations, which is just another way of writing SQL, and we ignore SQL
            
            column_names = model_class.column_names
            stringified_conditions.keys.each do |condition|
              return true unless column_names.include?(condition)
            end
          end
          
          false
        end
      end
      
      def initialize(init_conditions = {})
        add_klass_conditions!
        add_column_conditions!
        add_associations!
        self.conditions = init_conditions
      end
      
      # Determines if we should join the conditions with "AND" or "OR".
      #
      # === Examples
      #
      #   search.conditions.any = true # will join all conditions with "or", you can also set this to "true", "1", or "yes"
      #   search.conditions.any = false # will join all conditions with "and"
      def any=(value)
        associations.each { |association| association.any = value }
        @any = value
      end
      
      def any # :nodoc:
        any?
      end
      
      # Convenience method for determining if we should join the conditions with "AND" or "OR".
      def any?
        @any == true || @any == "true" || @any == "1" || @any == "yes"
      end
      
      # A list of joins to use when searching, includes relationships
      def auto_joins
        j = []
        associations.each do |association|
          next if association.conditions.blank?
          association_joins = association.auto_joins
          j << (association_joins.blank? ? association.relationship_name.to_sym : {association.relationship_name.to_sym => association_joins})
        end
        j.blank? ? nil : (j.size == 1 ? j.first : j)
      end
      
      def inspect
        "#<#{klass}Conditions#{conditions.blank? ? "" : " #{conditions.inspect}"}>"
      end
      
      # Sanitizes the conditions down into conditions that ActiveRecord::Base.find can understand.
      def sanitize
        return @conditions if @conditions
        merge_conditions(*(objects.collect { |object| object.sanitize } << {:any => any}))
      end
      
      # Allows you to set the conditions via a hash.
      def conditions=(value)
        case value
        when Hash          
          assert_valid_conditions(value)
          remove_conditions_from_protected_assignement(value).each do |condition, condition_value|
            next if meaningless?(condition_value) # ignore blanks on mass assignments
            send("#{condition}=", condition_value)
          end
        else
          reset_objects!
          @conditions = value
        end
      end
      
      # All of the active conditions (conditions that have been set)
      def conditions
        return @conditions if @conditions
        return if objects.blank?
        
        conditions_hash = {}
        objects.each do |object|
          if object.class < Searchgasm::Conditions::Base
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
          return true if self.class.added_associations
          
          klass.reflect_on_all_associations.each do |association|
            self.class.association_names << association.name.to_s
            
            self.class.class_eval <<-"end_eval", __FILE__, __LINE__
              def #{association.name}
                if @#{association.name}.nil?
                  @#{association.name} = Searchgasm::Conditions::Base.create_virtual_class(#{association.class_name}).new
                  @#{association.name}.relationship_name = "#{association.name}"
                  @#{association.name}.protect = protect
                  objects << @#{association.name}
                end
                @#{association.name}
              end
            
              def #{association.name}=(conditions); @conditions = nil; #{association.name}.conditions = conditions; end
              def reset_#{association.name}!; objects.delete(#{association.name}); @#{association.name} = nil; end
            end_eval
          end
          
          self.class.added_associations = true
        end
        
        def add_column_conditions!
          return true if self.class.added_column_conditions
          
          klass.columns.each do |column|
            self.class.conditions.each do |condition_klass|
              name = condition_klass.name_for_column(column)
              next if name.blank?
              add_condition!(condition_klass, name, column)
              condition_klass.aliases_for_column(column).each { |alias_name| add_condition_alias!(alias_name, name) }
            end
          end
          
          self.class.added_column_conditions = true
        end
        
        def add_condition!(condition, name, column = nil)
          self.class.condition_names << name
          
          self.class.class_eval <<-"end_eval", __FILE__, __LINE__
            def #{name}_object
              if @#{name}.nil?
                @#{name} = #{condition.name}.new(klass#{column.nil? ? "" : ", \"#{column.name}\""})
                objects << @#{name}
              end
              @#{name}
            end

            def #{name}; #{name}_object.value; end
            
            def #{name}=(value)
              if meaningless?(value) && #{name}_object.class.ignore_meaningless?
                reset_#{name}!
              else
                @conditions = nil
                #{name}_object.value = value
              end
            end
            
            def reset_#{name}!; objects.delete(#{name}_object); @#{name} = nil; end
          end_eval
        end
        
        def add_condition_alias!(alias_name, name)
          self.class.condition_names << alias_name
          
          self.class.class_eval do
            alias_method alias_name, name
            alias_method "#{alias_name}=", "#{name}="
          end
        end
        
        def add_klass_conditions!
          return true if self.class.added_klass_conditions
          
          self.class.conditions.each do |condition|
            name = condition.name_for_klass(klass)
            next if name.blank?
            add_condition!(condition, name)
            condition.aliases_for_klass(klass).each { |alias_name| add_condition_alias!(alias_name, name) }
          end
          
          self.class.added_klass_conditions = true
        end
        
        def assert_valid_conditions(conditions)
          conditions.stringify_keys.fast_assert_valid_keys(self.class.condition_names + self.class.association_names + ["any"])
        end
        
        def associations
          objects.select { |object| object.class < ::Searchgasm::Conditions::Base }
        end
        
        def objects
          @objects ||= []
        end
        
        def reset_objects!
          objects.each { |object| object.class < ::Searchgasm::Conditions::Base ? eval("@#{object.relationship_name} = nil") : eval("@#{object.name} = nil") }
          objects.clear
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