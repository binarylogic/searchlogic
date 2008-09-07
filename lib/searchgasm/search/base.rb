module Searchgasm #:nodoc:
  module Search #:nodoc:
    # = Searchgasm
    #
    # Please refer the README.rdoc for usage, examples, and installation.
    
    class Base
      include Searchgasm::Utilities
      
      # Options that ActiveRecord doesn't suppport, but Searchgasm does
      SPECIAL_FIND_OPTIONS = [:order_by, :order_as, :page, :per_page]
      
      # Valid options you can use when searching
      VALID_FIND_OPTIONS = ::ActiveRecord::Base.valid_find_options + SPECIAL_FIND_OPTIONS
      
      # Use these methods just like you would in ActiveRecord
      SEARCH_METHODS = [:all, :average, :calculate, :count, :find, :first, :maximum, :minimum, :sum]
      
      attr_accessor :klass, *::ActiveRecord::Base.valid_find_options
      
      # Used in the ActiveRecord methods to determine if Searchgasm should get involved or not.
      # This keeps Searchgasm out of the way unless it is needed.
      def self.needed?(klass, options)
        SPECIAL_FIND_OPTIONS.each do |option|
          return true if options.symbolize_keys.keys.include?(option)
        end
        
        Searchgasm::Conditions::Base.needed?(klass, options[:conditions])
      end
      
      def initialize(klass, init_options = {})
        self.klass = klass
        self.options = init_options
      end
      
      # Setup methods for searching
      SEARCH_METHODS.each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            self.options = args.extract_options!
            args << sanitize(:#{method})
            klass.#{method}(*args)
          end
        end_eval
      end
      
      def inspect
        options_as_nice_string = ::ActiveRecord::Base.valid_find_options.collect { |name| "#{name}: #{send(name)}" }.join(", ")
        "#<#{klass} #{options_as_nice_string}>"
      end
      
      def limit
        @limit ||= Config.per_page
      end
      
      def limit=(value)
        @limit = value.blank? || value == 0 ? nil : value.to_i
      end
      
      def offset=(value)
        @offset = value.to_i
      end
      
      def options=(values)
        return unless values.is_a?(Hash)
        values.symbolize_keys.assert_valid_keys(VALID_FIND_OPTIONS)
        values.each { |option, value| send("#{option}=", value) }
      end
      
      # Sanitizes everything down into options ActiveRecord::Base.find can understand
      def sanitize(for_method = nil)
        find_options = {}
        ::ActiveRecord::Base.valid_find_options.each do |find_option|
          value = send(find_option)
          next if value.blank? || (for_method == :count && [:limit, :offset].include?(find_option))
          find_options[find_option] = value
        end
        find_options
      end
    end
  end
end