module BinaryLogic
  module Searchgasm
    module Search
      class Base
        include Utilities
        
        SPECIAL_FIND_OPTIONS = [:order_by, :order_as, :page, :per_page]
        VALID_FIND_OPTIONS = ::ActiveRecord::Base.valid_find_options + SPECIAL_FIND_OPTIONS
        
        attr_accessor :klass
        attr_reader :conditions
        attr_writer :options
        
        def initialize(klass, options = {})
          self.klass = klass
          self.conditions = Conditions.new(klass)
          self.options = options
        end
        
        (::ActiveRecord::Base.valid_find_options - [:conditions]).each do |option|
          class_eval <<-SRC
            def #{option}(sanitize = false); options[:#{option}]; end
            def #{option}=(value); self.options[:#{option}] = value; end
          SRC
        end
        
        alias_method :per_page, :limit
        alias_method :per_page=, :limit=
        
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

        def options
          @options ||= {}
        end
        
        def options=(options)
          return unless options.is_a?(Hash)
          options.each { |option, value| send("#{option}=", value) }
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
          self.offset = value * limit
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
      end
    end
  end
end