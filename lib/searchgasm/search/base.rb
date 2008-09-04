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
        
        def self.needed?(klass, options)
          SPECIAL_FIND_OPTIONS.each do |option|
            return true if options.symbolize_keys.keys.include?(option)
          end
          
          Conditions.needed?(klass, options[:conditions])
        end
        
        def initialize(klass, options = {})
          self.klass = klass
          self.conditions = Conditions.new(klass)
          self.options = options
        end
        
        # Setup methods for all options for finding
        (::ActiveRecord::Base.valid_find_options - [:conditions]).each do |option|
          class_eval <<-end_eval
            def #{option}(sanitize = false); options[:#{option}]; end
            def #{option}=(value); self.options[:#{option}] = value; end
          end_eval
        end
                
        alias_method :per_page, :limit
        
        # Setup methods for searching
        [:all, :average, :calculate, :count, :find, :first, :maximum, :minimum, :sum].each do |method|
          class_eval <<-end_eval
            def #{method}(*args)
              self.options = args.extract_options!
              args << sanitize(:#{method})
              klass.#{method}(*args)
            end
          end_eval
        end
        
        def asc?
          !desc?
        end
        
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
        
        def desc?
          order_as == "DESC"
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
          options[:limit] = value.blank? || value == 0 ? nil : value.to_i
          self.page = @page unless @page.nil? # retry page now that the limit has changed
          options[:limit]
        end
        alias_method :per_page=, :limit=
        
        def next_page!
          raise("You are on the last page") if page == page_count
          self.page += 1
          all
        end
        
        def offset=(value)
          options[:offset] = value.to_i
          @page = nil
          options[:offset]
        end
        
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
        
        def order=(value)
          @order_by = nil
          options[:order] = value
        end
        
        def order_as
          return "DESC" if order.blank?
          order =~ /ASC$/i ? "ASC" : "DESC"
        end
        
        def order_as=(value)
          value = value.upcase
          
          if order.blank?
            self.order = "#{order_by} #{value}"
          else
            self.order.gsub!(/(ASC|DESC)$/i, value)
          end
          
          value
        end
        
        def order_by
          return @order_by if @order_by
          
          if !order.blank?
            # Reversege engineer order, only go 1 level deep with relationships
            order_parts = order.split(",").collect do |part|
              part.strip!
              part.gsub!(/ (ASC|DESC)$/i, "").gsub!(/(.*)\./, "")
              table_name = ($1 ? $1.gsub(/[^[:alpha:]]/, "") : nil)
              next if table_name && table_name != klass.table_name && !klass.reflect_on_association(table_name.to_sym) && !klass.reflect_on_association(table_name.singularize.to_sym)
              (table_name && table_name != klass.table_name) ? {table_name => part} : part
            end.compact
            order_parts.size <= 1 ? order_parts.first : order_parts
          else
            klass.primary_key
          end
        end
        
        def order_by=(value)
          order_by_parts = [value].flatten
          
          if protect?
            # Need to enhance this to support hashes
            order_by.each { |part| raise(ArgumentError, "You can not pass anything but columns names when the search is being protected") unless klass.column_names.include?(part) }
          end
          
          @order_by = value
          order_parts = []
          order_by_parts.each { |part| order_parts << "#{part} #{order_as}" }
          self.order = order_parts.join(", ")
          @order_by
        end
        
        def page
          return 1 if offset.blank? || limit.blank?
          (offset.to_f / limit).floor + 1
        end
        
        def page=(value)
          # Have to use optons[:offset], since self.offset= resets @page
          if value.nil?
            @page = value
            return options[:offset] = value
          end
          
          v = value.to_i
          @page = v
          
          if limit.blank?
            options[:offset] = nil
          else
            v -= 1 unless v == 0
            options[:offset] = v * limit
          end
          value
        end
        
        def page_count
          return 1 if per_page.blank? || per_page <= 0
          # Letting AR caching kick in with the count query
          (count / per_page.to_f).ceil
        end
        alias_method :page_total, :page_count
        
        def prev_page!
          raise("You are on the first page") if page == 1
          self.page -= 1
          all
        end
        
        def protect=(value)
          conditions.protect = value
          @protect = value
        end
        
        def protect?
          protect == true
        end
        
        def sanitize(for_method = nil)
          find_options = {}
          ::ActiveRecord::Base.valid_find_options.each do |find_option|
            next if for_method == :count && [:limit, :offset].include?(find_option)
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