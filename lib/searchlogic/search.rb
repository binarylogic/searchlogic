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
      @conditions ||= {}
      self.conditions = conditions if conditions.is_a?(Hash)
    end
    
    def clone
      self.class.new(klass, current_scope && current_scope.clone, conditions.clone)
    end
    
    # Returns a hash of the current conditions set.
    def conditions
      mass_conditions.clone.merge(@conditions)
    end
    
    # Accepts a hash of conditions.
    def conditions=(values)
      values.each do |condition, value|
        # if a condition name ends with "(1i)", assume it's date / datetime
        if condition =~ /(.*)\(1i\)$/
          date_scope_name = $1
          date_parts = (1..6).to_a.map do |idx|
            values.delete("#{ date_scope_name }(#{ idx }i)")
          end.reject{|s| s.blank? }.map{|s| s.to_i }

          # did we get enough info to build a time?
          if date_parts.length >= 3
            values[date_scope_name] = Time.zone.local(*date_parts)
          end
        end
      end

      values.each do |condition, value|
        mass_conditions[condition.to_sym] = value
        value.delete_if { |v| ignore_value?(v) } if value.is_a?(Array)
        next if ignore_value?(value)
        send("#{condition}=", value)
      end
    end
    
    # Delete a condition from the search. Since conditions map to named scopes,
    # if a named scope accepts a parameter there is no way to actually delete
    # the scope if you do not want it anymore. A nil value might be meaningful
    # to that scope.
    def delete(*names)
      names.each do |name|
        @conditions.delete(name.to_sym)
        mass_conditions.delete(name)
      end
      self
    end
    
    # Returns the column we are currently ordering by
    def ordering_by
      order && order.to_s.gsub(/^(ascend|descend)_by_/, '')
    end
    
    private
      def method_missing(name, *args, &block)
        condition_name = condition_name(name)
        scope_name = scope_name(condition_name)
        
        if setter?(name)
          if scope?(scope_name)
            if args.size == 1
              write_condition(
                condition_name,
                type_cast(
                  args.first,
                  cast_type(scope_name),
                  scope_options(scope_name).respond_to?(:searchlogic_options) ? scope_options(scope_name).searchlogic_options : {}
                )
              )
            else
              write_condition(condition_name, args)
            end
          else
            raise UnknownConditionError.new(condition_name)
          end
        elsif scope?(scope_name) && args.size <= 1
          if args.size == 0
            read_condition(condition_name)
          else
            send("#{condition_name}=", *args)
            self
          end
        else
          scope = conditions_array.inject(klass.scoped(current_scope) || {}) do |scope, condition|
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
            elsif arity == -1
              scope.send(scope_name, *(value.is_a?(Array) ? value : [value]))
            else
              scope.send(scope_name, value)
            end
          end
          scope.send(name, *args, &block)
        end
      end
      
      # This is here as a hook to allow people to modify the order in which the conditions are called, for whatever reason.
      def conditions_array
        @conditions.to_a
      end
      
      def normalize_scope_name(scope_name)
        case
        when klass.scopes.key?(scope_name.to_sym) then scope_name.to_sym
        when klass.column_names.include?(scope_name.to_s) then "#{scope_name}_equals".to_sym
        else scope_name.to_sym
        end
      end
      
      def setter?(name)
        !(name.to_s =~ /=$/).nil?
      end
      
      def condition_name(name)
        condition = name.to_s.match(/(\w+)=?$/)
        condition ? condition[1].to_sym : nil
      end
      
      def write_condition(name, value)
        @conditions[name] = value
      end
      
      def read_condition(name)
        @conditions[name]
      end
      
      def mass_conditions
        @mass_conditions ||= {}
      end
      
      def scope_name(condition_name)
        condition_name && normalize_scope_name(condition_name)
      end
      
      def scope?(scope_name)
        klass.scopes.key?(scope_name) || klass.condition?(scope_name)
      end
      
      def scope_options(name)
        klass.send(name, nil) if !klass.respond_to?(name) # We need to set up the named scope if it doesn't exist, so we can get a value for named_scope_options
        klass.named_scope_options(name)
      end
      
      def cast_type(name)
        named_scope_options = scope_options(name)
        arity = klass.named_scope_arity(name)
        if !arity || arity == 0
          :boolean
        else
          named_scope_options.respond_to?(:searchlogic_options) ? named_scope_options.searchlogic_options[:type] : :string
        end
      end
      
      def type_cast(value, type, options = {})
        case value
        when Array
          value.collect { |v| type_cast(v, type) }
        when Range
          Range.new(type_cast(value.first, type), type_cast(value.last, type))
        else
          # Let's leverage ActiveRecord's type casting, so that casting is consistent
          # with the other models.
          column_for_type_cast = ::ActiveRecord::ConnectionAdapters::Column.new("", nil)
          column_for_type_cast.instance_variable_set(:@type, type)
          casted_value = column_for_type_cast.type_cast(value)
          
          if Time.zone && casted_value.is_a?(Time)
            if value.is_a?(String)
              if options[:skip_conversion]
                casted_value.utc
              else
                (casted_value + (Time.zone.utc_offset * -1)).in_time_zone
              end
            else
              if options[:skip_conversion]
                casted_value.utc
              else
                casted_value.in_time_zone
              end
            end
          else
            casted_value
          end
        end
      end
      
      def ignore_value?(value)
        (value.is_a?(String) && value.blank?) || (value.is_a?(Array) && value.empty?)
      end
  end
end
