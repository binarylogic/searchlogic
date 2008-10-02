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
        
        def column_details # :nodoc:
          return @column_details if @column_details
          
          @column_details = []
          
          klass.columns.each do |column|
            column_detail = {:column => column}
            column_detail[:aliases] = case column.type
            when :datetime, :time, :timestamp
              [column.name.gsub(/_at$/, "")]
            when :date
              [column.name.gsub(/_at$/, "")]
            else
              []
            end
            
            @column_details << column_detail
          end
          
          @column_details
        end
        
        # Registers a condition as an available condition for a column or a class. MySQL supports a "sounds like" function. I want to use it, so let's add it.
        #
        # === Example
        #
        #   # config/initializers/searchgasm.rb
        #   # Actual function for MySQL databases only
        #   class SoundsLike < Searchgasm::Condition::Base
        #     # The name of the conditions. By default its the name of the class, if you want alternate or alias conditions just add them on.
        #     # If you don't want to add aliases you don't even need to define this method
        #     def self.name_for_column(column)
        #       super
        #     end
        #
        #     # You can return an array or a string. NOT a hash, because all of these conditions
        #     # need to eventually get merged together. The array or string can be anything you would put in
        #     # the :conditions option for ActiveRecord::Base.find(). Also notice the column_sql variable. This is essentail
        #     # for applying modifiers and should be used in your conditions wherever you want the column.
        #     def to_conditions(value)
        #       ["#{column_sql} SOUNDS LIKE ?", value]
        #     end
        #   end
        #
        #   Searchgasm::Seearch::Conditions.register_condition(SoundsLike)
        def register_condition(condition_class)
          raise(ArgumentError, "You can only register conditions that extend Searchgasm::Condition::Base") unless condition_class.ancestors.include?(Searchgasm::Condition::Base)
          conditions << condition_class unless conditions.include?(condition_class)
        end
        
        # A list of available condition type classes
        def conditions
          @@conditions ||= []
        end
        
        # Registers a modifier as an available modifier for each column.
        #
        # === Example
        #
        #   # config/initializers/searchgasm.rb
        #   class Ceil < Searchgasm::Modifiers::Base
        #     # The name of the modifier. By default its the name of the class, if you want alternate or alias modifiers just add them on.
        #     # If you don't want to add aliases you don't even need to define this method
        #     def self.modifier_names
        #       super + ["round_up"]
        #     end
        #
        #     # The name of the method in the connection adapters (see below). By default its the name of your class suffixed with "_sql".
        #     # So in this example it would be "ceil_sql". Unless you want to change that you don't need to define this method.
        #     def self.adapter_method_name
        #       super
        #     end
        #
        #     # This is the type of value returned from the modifier. This is neccessary for typcasting values for the modifier when
        #     # applied to a column
        #     def self.return_type
        #       :integer
        #     end
        #   end
        #
        #   Searchgasm::Seearch::Conditions.register_modifiers(Ceil)
        #
        # Now here's the fun part, applying this modifier to each connection adapter. Some databases call modifiers differently. If they all apply them the same you can
        # add in the function to ActiveRecord::ConnectionAdapters::AbstractAdapter, otherwise you need to add them to each
        # individually: ActiveRecord::ConnectionAdapters::MysqlAdapter, ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, ActiveRecord::ConnectionAdapters::SQLiteAdapter
        #
        # Do this by includine a model with your method. The name of your method, by default, is: #{modifier_name}_sql. So in the example above it would be "ceil_sql"
        #
        #   module CeilAdapterMethod
        #     def ceil_sql(column_name)
        #       "CEIL(#{column_name})"
        #     end
        #   end
        #
        #   ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, CeilAdapterMethod)
        #   # ... include for the rest of the adapters
        def register_modifier(modifier_class)
          raise(ArgumentError, "You can only register conditions that extend Searchgasm::Modifiers::Base") unless modifier_class.ancestors.include?(Searchgasm::Modifiers::Base)
          modifiers << modifier_class unless modifiers.include?(modifier_class)
        end
        
        # A list of available modifier classes
        def modifiers
          @@modifiers ||= []
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
        associations.each { |name, association| association.any = value }
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
        associations.each do |name, association|
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
        merge_conditions(*(objects.collect { |name, object| object.sanitize } << {:any => any}))
      end
      
      # Allows you to set the conditions via a hash.
      def conditions=(value)
        case value
        when Hash
          assert_valid_conditions(value)
          remove_conditions_from_protected_assignement(value).each do |condition, condition_value|
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
        objects.each do |name, object|
          if object.class < Searchgasm::Conditions::Base
            relationship_conditions = object.conditions
            next if relationship_conditions.blank?
            conditions_hash[object.relationship_name.to_sym] = relationship_conditions
          else
            next if object.meaningless_value?
            conditions_hash[name] = object.value
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
                if objects[:#{association.name}].nil?
                  objects[:#{association.name}] = Searchgasm::Conditions::Base.create_virtual_class(#{association.class_name}).new
                  objects[:#{association.name}].relationship_name = "#{association.name}"
                  objects[:#{association.name}].protect = protect
                end
                objects[:#{association.name}]
              end
            
              def #{association.name}=(conditions); @conditions = nil; #{association.name}.conditions = conditions; end
              def reset_#{association.name}!; objects.delete(:#{association.name}); end
            end_eval
          end
          
          self.class.added_associations = true
        end
        
        def extract_column_and_condition_from_method_name(name)
          name_parts = name.gsub("=", "").split("_")
          
          condition_parts = []
          column = nil
          while column.nil? && name_parts.size > 0
            possible_column_name = name_parts.join("_")
            
            self.class.column_details.each do |column_detail|
              if column_detail[:column].name == possible_column_name || column_detail[:aliases].include?(possible_column_name)
                column = column_detail
                break
              end
            end
            
            condition_parts << name_parts.pop if !column
          end
          
          return if column.nil?
          
          condition_name = condition_parts.reverse.join("_")
          condition = nil
          
          # Find the real condition
          self.class.conditions.each do |condition_klass|
            if condition_klass.condition_names_for_column.include?(condition_name)
              condition = condition_klass
              break
            end
          end
                                         
          [column, condition]
        end
        
        def breakdown_method_name(name)
          column_detail, condition_klass = extract_column_and_condition_from_method_name(name)
          if !column_detail.nil? && !condition_klass.nil?
            # There were no modifiers
            return [[], column_detail, condition_klass]
          else
            # There might be modifiers
            name_parts = name.split("_of_")
            column_detail, condition_klass = extract_column_and_condition_from_method_name(name_parts.pop)
            if !column_detail.nil? && !condition_klass.nil?
              # There were modifiers, lets get their real names
              modifier_klasses = []
              name_parts.each do |modifier_name|
                size_before = modifier_klasses.size
                self.class.modifiers.each do |modifier_klass|
                  if modifier_klass.modifier_names.include?(modifier_name)
                    modifier_klasses << modifier_klass
                    break
                  end
                end
                return if modifier_klasses.size == size_before # there was an invalid modifer, return nil for everything and let it act as a nomethoderror
              end
              
              return [modifier_klasses, column_detail, condition_klass]
            end
          end
          
          nil
        end
        
        def build_method_name(modifier_klasses, column_name, condition_name)
          modifier_name_parts = []
          modifier_klasses.each { |modifier_klass| modifier_name_parts << modifier_klass.modifier_names.first }
          method_name_parts = []
          method_name_parts << modifier_name_parts.join("_of_") unless modifier_name_parts.blank?
          method_name_parts << column_name
          method_name_parts << condition_name
          method_name_parts.join("_")
        end
        
        def method_missing(name, *args, &block)
          modifier_klasses, column_detail, condition_klass = breakdown_method_name(name.to_s)
          if !column_detail.nil? && !condition_klass.nil?
            method_name = build_method_name(modifier_klasses, column_detail[:column].name, condition_klass.condition_names_for_column.first)
            column_type = column_sql = nil
            if !modifier_klasses.blank?
              # Find the column type
              column_type = modifier_klasses.first.return_type
              
              # Build the column sql
              column_sql = "#{klass.connection.quote_table_name(klass.table_name)}.#{klass.connection.quote_column_name(column_detail[:column].name)}"
              modifier_klasses.each do |modifier_klass|
                next unless klass.connection.respond_to?(modifier_klass.adapter_method_name)
                column_sql = klass.connection.send(modifier_klass.adapter_method_name, column_sql)
              end
            end
            
            add_condition!(condition_klass, method_name, column_detail[:column], column_type, column_sql)
            
            ([column_detail[:column].name] + column_detail[:aliases]).each do |column_name|
              condition_klass.condition_names_for_column.each do |condition_name|
                alias_method_name = build_method_name(modifier_klasses, column_name, condition_name)
                add_condition_alias!(alias_method_name, method_name) unless alias_method_name == method_name
              end
            end
            
            send(method_name + (name.to_s =~ /=$/ ? "=" : ""), *args, &block)
          else
            super
          end
        end
        
        def add_condition!(condition, name, column = nil, column_type = nil, column_sql = nil)
          self.class.condition_names << name
          
          self.class.class_eval <<-"end_eval", __FILE__, __LINE__
            def #{name}_object
              if objects[:#{name}].nil?
                objects[:#{name}] = #{condition.name}.new(klass, #{column.blank? ? "nil" : "klass.columns_hash['#{column.name}']"}, #{column_type.blank? ? "nil" : "\"#{column_type}\""}, #{column_sql.blank? ? "nil" : "\"#{column_sql.gsub('"', '\"')}\""})
              end
              objects[:#{name}]
            end

            def #{name}; #{name}_object.value; end
            
            def #{name}=(value)
              @conditions = nil
              
              #{name}_object.value = value
              reset_#{name}! if #{name}_object.meaningless_value?
              value
            end
            
            def reset_#{name}!; objects.delete(:#{name}); end
          end_eval
        end
        
        def add_condition_alias!(alias_name, name)
          self.class.condition_names << alias_name
          
          self.class.class_eval do
            alias_method "#{alias_name}_object", "#{name}_object"
            alias_method alias_name, name
            alias_method "#{alias_name}=", "#{name}="
            alias_method "reset_#{alias_name}!", "reset_#{name}!"
          end
        end
        
        def assert_valid_conditions(conditions)
          conditions.each do |condition, value|
            raise(ArgumentError, "The #{condition} condition is not a valid condition") if !(self.class.condition_names + self.class.association_names + ["any"]).include?(condition.to_s) && respond_to?(condition)
          end
        end
        
        def associations
          associations = {}
          objects.each do |name, object|
            associations[name] = object if object.class < ::Searchgasm::Conditions::Base
          end
          associations
        end
        
        def objects
          @objects ||= {}
        end
        
        def reset_objects!
          objects.each { |name, object| object.class < ::Searchgasm::Conditions::Base ? eval("@#{object.relationship_name} = nil") : eval("@#{name} = nil") }
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