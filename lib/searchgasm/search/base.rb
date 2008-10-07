module Searchgasm #:nodoc:
  module Search #:nodoc:
    # = Searchgasm
    #
    # Please refer the README.rdoc for usage, examples, and installation.
    class Base
      include Searchgasm::Shared::Utilities
      include Searchgasm::Shared::VirtualClasses
      
      # Options ActiveRecord allows when searching
      AR_FIND_OPTIONS = ::ActiveRecord::Base.valid_find_options
      
      # Options ActiveRecord allows when performing calculations
      AR_CALCULATIONS_OPTIONS = (::ActiveRecord::Base.valid_calculations_options - [:select, :limit, :offset, :order, :group])
      
      AR_OPTIONS = (AR_FIND_OPTIONS + AR_CALCULATIONS_OPTIONS).uniq
      
      # Options that ActiveRecord doesn't suppport, but Searchgasm does
      SPECIAL_FIND_OPTIONS = [:order_by, :order_as, :page, :per_page, :priority_order, :priority_order_by, :priority_order_as]
      
      # Valid options you can use when searching
      OPTIONS = SPECIAL_FIND_OPTIONS + AR_OPTIONS # the order is very important, these options get set in this order
      
      attr_accessor *AR_OPTIONS
      attr_reader :auto_joins
      
      class << self
        # Used in the ActiveRecord methods to determine if Searchgasm should get involved or not.
        # This keeps Searchgasm out of the way unless it is needed.
        def needed?(model_class, options)
          return false if options.blank?
          
          SPECIAL_FIND_OPTIONS.each do |option|
            return true if options.symbolize_keys.keys.include?(option)
          end
                    
          Searchgasm::Conditions::Base.needed?(model_class, options[:conditions])
        end
      end
      
      def initialize(init_options = {})
        self.options = init_options
      end
      
      # Flag to determine if searchgasm is acting as a filter for the ActiveRecord search methods.
      # The purpose of this is to determine if Config.per_page should be implemented.
      def acting_as_filter=(value)
        @acting_as_filter = value
      end
      
      # See acting_as_filter=
      def acting_as_filter?
        @acting_as_filter == true
      end
      
      # Specific implementation of cloning
      def clone
        options = {}
        (OPTIONS - [:conditions]).each { |option| options[option] = send(option) }
        options[:conditions] = conditions.conditions
        obj = self.class.new(options)
        obj.protect = protected?
        obj.scope = scope
        obj
      end
      alias_method :dup, :clone
      
      # Makes using searchgasm in the console less annoying and keeps the output meaningful and useful
      def inspect
        current_find_options = {}
        (AR_OPTIONS - [:conditions]).each do |option|
          value = send(option)
          next if value.nil?
          current_find_options[option] = value
        end
        conditions_value = conditions.conditions
        current_find_options[:conditions] = conditions_value unless conditions_value.blank?
        current_find_options[:scope] = scope unless scope.blank?
        "#<#{klass}Search #{current_find_options.inspect}>"
      end
      
      # Searchgasm requires that all joins be left outer joins for conditions and ordering to work properly
      def joins
        joins_sql = ""
        all_joins = auto_joins
        
        case @joins
        when String
          joins_sql += @joins
        else
          all_joins = merge_joins(@joins, all_joins)
        end
        
        return if joins_sql.blank? && all_joins.blank?
        
        unless all_joins.blank?
          join_dependency = ::ActiveRecord::Associations::ClassMethods::JoinDependency.new(klass, all_joins, nil)
          joins_sql += " " unless joins_sql.blank?
          joins_sql += join_dependency.join_associations.collect { |assoc| assoc.association_join }.join
        end
        
        joins_sql
      end
      
      def limit=(value)
        @set_limit = true
        @limit = value.blank? || value == 0 ? nil : value.to_i
      end
      
      def limit
        @limit ||= Config.per_page if !acting_as_filter? && !@set_limit
        @limit
      end
      
      def offset=(value)
        @offset = value.blank? ? nil : value.to_i
      end

      def options=(values)
        return unless values.is_a?(Hash)
        values.symbolize_keys.fast_assert_valid_keys(OPTIONS)
        values.each { |key, value| send("#{key}=", value) }
      end
      
      # Sanitizes everything down into options ActiveRecord::Base.find can understand
      def sanitize(searching = true)
        find_options = {}
        
        (searching ? AR_FIND_OPTIONS : AR_CALCULATIONS_OPTIONS).each do |find_option|
          value = send(find_option)
          next if value.blank?
          find_options[find_option] = value
        end
        
        find_options
      end
      
      def scope
        @scope ||= {}
      end
    end
  end
end