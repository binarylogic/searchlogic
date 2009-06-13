module Searchlogic
  class Search
    module Implementation
      def search(conditions = {})
        Search.new(self, scope(:find), conditions)
      end
    end
    
    class UnknownConditionError < StandardError
      def initialize(condition)
        msg = "The #{condition} is not a valid condition. You may only use conditions that map to a named scope"
        super(msg)
      end
    end
    
    attr_accessor :klass, :current_scope, :conditions
    
    def initialize(klass, current_scope, conditions = {})
      self.klass = klass
      self.current_scope = current_scope
      self.conditions = conditions if conditions.is_a?(Hash)
    end
    
    def conditions
      @conditions ||= {}
    end
    
    def conditions=(values)
      values.each do |condition, value|
        value.delete_if { |v| v.blank? } if value.is_a?(Array)
        next if value.blank?
        send("#{condition}=", value)
      end
    end
    
    private
      def method_missing(name, *args, &block)
        if name.to_s =~ /(\w+)=$/
          condition = $1.to_sym
          scope_name = normalize_scope_name($1)
          if scope?(scope_name)
            conditions[condition] = type_cast(args.first, cast_type(scope_name))
          else
            raise UnknownConditionError.new(name)
          end
        elsif scope?(normalize_scope_name(name))
          conditions[name]
        else
          scope = conditions.inject(klass.scoped(current_scope)) do |scope, condition|
            scope_name, value = condition
            scope_name = normalize_scope_name(scope_name)
            klass.send(scope_name, value) if !klass.respond_to?(scope_name)
            arity = klass.named_scope_arity(scope_name)
            
            if !arity || arity == 0
              if value == true
                scope.send(scope_name)
              else
                scope
              end
            else
              scope.send(scope_name, value)
            end
          end
          scope.send(name, *args, &block)
        end
      end
      
      def normalize_scope_name(scope_name)
        klass.column_names.include?(scope_name.to_s) ? "#{scope_name}_equals".to_sym : scope_name.to_sym
      end
      
      def scope?(scope_name)
        klass.scopes.key?(scope_name) || klass.condition?(scope_name)
      end
      
      def cast_type(name)
        klass.send(name, nil) if !klass.respond_to?(name) # We need to set up the named scope if it doesn't exist, so we can get a value for named_ssope_options
        named_scope_options = klass.named_scope_options(name)
        arity = klass.named_scope_arity(name)
        if !arity || arity == 0
          :boolean
        else
          named_scope_options.respond_to?(:searchlogic_arg_type) ? named_scope_options.searchlogic_arg_type : :string
        end
      end
      
      def type_cast(value, type)
        case value
        when Array
          value.collect { |v| type_cast(v, type) }
        else
          # Let's leverage ActiveRecord's type casting, so that casting is consistent
          # with the other models.
          column_for_type_cast = ActiveRecord::ConnectionAdapters::Column.new("", nil)
          column_for_type_cast.instance_variable_set(:@type, type)
          column_for_type_cast.type_cast(value)
        end
      end
  end
end