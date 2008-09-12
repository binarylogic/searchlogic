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
          class_search_name = "::Searchgasm::Cache::#{model_class.name}Search"
          
          begin
            eval(class_search_name)
          rescue NameError
            # The method definitions are for performance, bottlenecks found with ruby-prof
            eval <<-end_eval
              class #{class_search_name} < ::Searchgasm::Search::Base
                def self.klass
                  #{model_class.name}
                end
                
                def klass
                  #{model_class.name}
                end
              end
              
              #{class_search_name}
            end_eval
          end
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
      
      # Flag to determine if searchgasm is acting as a filter for the ActiveRecord search methods.
      # The purpose of this is to determine if Config.per_page should be implemented.
      def acting_as_filter=(value)
        @acting_as_filter == true
      end
      
      # See acting_as_filter=
      def acting_as_filter?
        @acting_as_filter == true
      end
      
      # Makes using searchgasm in the console less annoying and keeps the output meaningful and useful
      def inspect
        options_as_nice_string = ::ActiveRecord::Base.valid_find_options.collect { |name| "#{name}: #{send(name)}" }.join(", ")
        "#<#{klass} #{options_as_nice_string}>"
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
        @offset = value.to_i
      end
      
      def options=(values)
        return unless values.is_a?(Hash)
        values.symbolize_keys.fast_assert_valid_keys(VALID_FIND_OPTIONS)
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