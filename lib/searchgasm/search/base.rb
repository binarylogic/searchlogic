module Searchgasm #:nodoc:
  module Search #:nodoc:
    # = Searchgasm
    #
    # Please refer the README.rdoc for usage, examples, and installation.
    
    class Base
      include Searchgasm::Shared::Utilities
      include Searchgasm::Shared::Searching
      include Searchgasm::Shared::VirtualClasses
      
      # Options that ActiveRecord doesn't suppport, but Searchgasm does
      SPECIAL_FIND_OPTIONS = [:order_by, :order_as, :page, :per_page]
      
      # Valid options you can use when searching
      VALID_FIND_OPTIONS = SPECIAL_FIND_OPTIONS + ::ActiveRecord::Base.valid_find_options # the order is very important, these options get set in this order
      
      attr_accessor *::ActiveRecord::Base.valid_find_options
      
      class << self
        # Used in the ActiveRecord methods to determine if Searchgasm should get involved or not.
        # This keeps Searchgasm out of the way unless it is needed.
        def needed?(model_class, options)
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
      
      # Makes using searchgasm in the console less annoying and keeps the output meaningful and useful
      def inspect
        current_find_options = {}
        ::ActiveRecord::Base.valid_find_options.each do |option|
          value = send(option)
          next if value.nil?
          current_find_options[option] = value
        end
        current_find_options[:scope] = scope unless scope.blank?
        "#<#{klass}Search #{current_find_options.inspect}>"
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
        values.symbolize_keys.fast_assert_valid_keys(VALID_FIND_OPTIONS)
        
        # Do the special options first, and then the core options last, since the core options take precendence
        VALID_FIND_OPTIONS.each do |option|
          next unless values.has_key?(option)
          send("#{option}=", values[option])
        end
        
        values
      end
      
      # Sanitizes everything down into options ActiveRecord::Base.find can understand
      def sanitize
        find_options = {}
        ::ActiveRecord::Base.valid_find_options.each do |find_option|
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