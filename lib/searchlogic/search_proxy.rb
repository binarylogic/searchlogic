module Searchlogic
  class SearchProxy
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
        send("#{condition}=", value)
      end
    end
    
    private
      def method_missing(name, *args, &block)
        if name.to_s =~ /(\w+)=$/
          condition = $1.to_sym
          scope_name = normalize_scope_name($1)
          if scope?(scope_name)
            conditions[condition] = args.first
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
            
            if (!arity || arity == 0) && !true?(value)
              scope
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
      
      def true?(value)
        value == true || value == 'true' || value == '1'
      end
  end
end