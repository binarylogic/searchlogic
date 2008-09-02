module BinaryLogic
  module Searchgasm
    module Search      
      class Base
        include Utilities
        
        SPECIAL_FIND_OPTIONS = [:order_by, :order_as, :page, :per_page]
        VALID_FIND_OPTIONS = ::ActiveRecord::Base.valid_find_options + SPECIAL_FIND_OPTIONS
        SAFE_OPTIONS = SPECIAL_FIND_OPTIONS + [:conditions, :limit, :offset]
        VULNERABLE_OPTIONS = VALID_FIND_OPTIONS - SAFE_OPTIONS
        
        attr_accessor :klass
        attr_reader :conditions, :protect
        attr_writer :options
        
        def initialize(klass, options = {})
          self.klass = klass
          self.conditions = Conditions.new(klass)
          self.options = options
        end
        
        (::ActiveRecord::Base.valid_find_options - [:conditions]).each do |option|
          src = <<-SRC
            def #{option}(sanitize = false); options[:#{option}]; end
            def #{option}=(value); self.options[:#{option}] = value; end
          SRC
          
          class_eval src
        end
        
        alias_method :per_page, :limit
        
        def all
          klass.all(sanitize)
        end
        alias_method :search, :all
        
        def conditions=(value)
          case value
          when Conditions
            @conditions = value
          else
            @conditions.value = value
          end
        end
        
        def conditions(sanitize = false)
          sanitize ? @conditions.sanitize : @conditions
        end
        
        def find(target)
          case target
          when :all then all
          when :first then first
          else raise(ArgumentError, "The argument must be :all or :first")
          end
        end
        
        def first
          klass.first(sanitize)
        end
        
        def include(sanitize = false)
          includes = [self.options[:include], conditions.includes].flatten.compact
          includes.blank? ? nil : (includes.size == 1 ? includes.first : includes)
        end
        
        def inspect
          options_as_nice_string = ::ActiveRecord::Base.valid_find_options.collect { |name| "#{name}: #{send(name)}" }.join(", ")
          "#<#{klass} #{options_as_nice_string}>"
        end
        
        def limit=(value)
          return options[:limit] = nil if value.nil? || value == 0
          
          old_limit = options[:limit]
          options[:limit] = value
          self.page = @page if !@page.blank? # retry page now that limit is set
          value
        end
        alias_method :per_page=, :limit=
        
        def options
          @options ||= {}
        end
        
        def options=(values)
          return unless values.is_a?(Hash)
          self.protect = values.delete(:protect) if values.has_key?(:protect) # make sure we do this first
          values.symbolize_keys.assert_valid_keys(VALID_FIND_OPTIONS)
          frisk!(values) if protect?
          values.each { |option, value| send("#{option}=", value) }
        end
        
        def order_as
          return "DESC" if order.blank?
          order =~ /ASC$/i ? "ASC" : "DESC"
        end
        
        def order_as=(value)
          # reset order
        end
        
        def order_by
          # need to return a cached value of order_by, not smart to figure it out from order
        end
        
        def order_by=(value)
          # do your magic here and set order approperiately
        end
        
        def page
          return 1 if offset.blank?
          (offset.to_f / limit).ceil
        end
        
        def page=(value)
          return self.offset = nil if value.nil?
          
          if limit.blank?
            @page = value
          else
            @page = nil
            self.offset = value * limit
          end
          value
        end
        
        def protect=(value)
          conditions.protect = value
          @protect = value
        end
        
        def protect?
          protect == true
        end
        
        def reset!
          conditions.reset!
          self.options = {}
        end
        
        def sanitize
          find_options = {}
          ::ActiveRecord::Base.valid_find_options.each do |find_option|
            value = send(find_option, true)
            next if value.blank?
            find_options[find_option] = value
          end
          find_options
        end
        
        def scope
          conditions.scope
        end
        
        def scope=(value)
          conditions.scope = value
        end
        
        private
          def order_by_safe?(order_by)
            return true if order_by.blank?
            
            column_names = klass.column_names
            
            [order_by].flatten.each do |column|
              case column
              when Hash
                return false unless order_by_safe?(column.to_a)
              when Array
                return false unless order_by_safe?(column)
              else
                return false unless column_names.include?(column)
              end
            end
            
            true
          end
          
          def frisk!(options)
            options.symbolize_keys.assert_valid_keys(SAFE_OPTIONS)
            raise(ArgumentError, ":order_by can only contain colum names in the string, hash, or array format") unless order_by_safe?(options[:order_by])
          end
      end
    end
  end
end