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
        
        # Creates virtual classes for the class passed to it. This is a neccesity for keeping dynamically created method
        # names specific to models. It provides caching and helps a lot with performance.
        def create_virtual_class(model_class)
          class_search_name = "::#{model_class.name}Search"
          
          begin
            class_search_name.constantize
          rescue NameError
            eval <<-end_eval
              class #{class_search_name} < ::Searchgasm::Search::Base; end;
            end_eval
          
            class_search_name.constantize
          end
        end
        
        # The class / model we are searching
        def klass
          # Can't cache this because thin and mongrel don't play nice with caching constants
          name.split("::").last.gsub(/Search$/, "").constantize
        end
      end
      
      def initialize(init_options = {})
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
      
      # Makes using searchgasm in the console less annoying and keeps the output meaningful and useful
      def inspect
        options_as_nice_string = ::ActiveRecord::Base.valid_find_options.collect { |name| "#{name}: #{send(name)}" }.join(", ")
        "#<#{klass} #{options_as_nice_string}>"
      end
      
      # Convenience method for self.class.klass
      def klass
        self.class.klass
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