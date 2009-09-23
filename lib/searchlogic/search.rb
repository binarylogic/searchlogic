module Searchlogic
  # A class that acts like a model, creates attr_accessors for named_scopes, and then
  # chains together everything when an "action" method is called. It basically makes
  # implementing search forms in your application effortless:
  #
  #   search = User.search
  #   search.username_like = "bjohnson"
  #   search.all
  #
  # Is equivalent to:
  #
  #   User.search(:username_like => "bjohnson").all
  #
  # Is equivalent to:
  #
  #   User.username_like("bjohnson").all
  class Search
    # Responsible for adding a "search" method into your models.
    module Implementation
      # Additional method, gets aliased as "search" if that method
      # is available. A lot of other libraries like to use "search"
      # as well, so if you have a conflict like this, you can use
      # this method directly.
      def searchlogic(conditions = {})
        Search.new(self, scope(:find), conditions)
      end
    end
    
    # Is an invalid condition is used this error will be raised. Ex:
    #
    #   User.search(:unkown => true)
    #
    # Where unknown is not a valid named scope for the User model.
    class UnknownConditionError < StandardError
      def initialize(condition)
        msg = "The #{condition} is not a valid condition. You may only use conditions that map to a named scope"
        super(msg)
      end
    end
    
    attr_accessor :klass, :current_scope, :conditions
    undef :id if respond_to?(:id)
    
    # Creates a new search object for the given class. Ex:
    #
    #   Searchlogic::Search.new(User, {}, {:username_like => "bjohnson"})
    def initialize(klass, current_scope, conditions = {})
      self.klass = klass
      self.current_scope = current_scope
      self.conditions = conditions if conditions.is_a?(Hash)
    end
    
    def clone
      self.class.new(klass, current_scope && current_scope.clone, conditions.clone)
    end
    
    # Returns a hash of the current conditions set.
    def conditions
      @conditions ||= {}
    end
    
    # Accepts a hash of conditions.
    def conditions=(values)
      values.each do |condition, value|
        value.delete_if { |v| v.blank? } if value.is_a?(Array)
        next if value.blank?
        send("#{condition}=", value)
      end
    end
    
    # Delete a condition from the search. Since conditions map to named scopes,
    # if a named scope accepts a parameter there is no way to actually delete
    # the scope if you do not want it anymore. A nil value might be meaningful
    # to that scope.
    def delete(*names)
      names.each { |name| @conditions.delete(name.to_sym) }
      self
    end
    
    private
      def method_missing(name, *args, &block)
        condition_name = condition_name(name)
        scope_name = scope_name(condition_name)
        
        if setter?(name)
          if scope?(scope_name)
            conditions[condition_name] = type_cast(args.first, cast_type(scope_name))
          else
            raise UnknownConditionError.new(condition_name)
          end
        elsif scope?(scope_name)
          if args.size > 0
            send("#{condition_name}=", *args)
            self
          else
            conditions[condition_name]
          end
        else
          scope = conditions.inject(klass.scoped(current_scope) || {}) do |scope, condition|
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
      
      def setter?(name)
        !(name.to_s =~ /=$/).nil?
      end
      
      def condition_name(name)
        condition = name.to_s.match(/(\w+)=?$/)[1]
        condition ? condition.to_sym : nil
      end
      
      def scope_name(condition_name)
        condition_name && normalize_scope_name(condition_name)
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
          column_for_type_cast = ::ActiveRecord::ConnectionAdapters::Column.new("", nil)
          column_for_type_cast.instance_variable_set(:@type, type)
          value = column_for_type_cast.type_cast(value)
          Time.zone && value.is_a?(Time) ? value.in_time_zone : value
        end
      end
  end
end
