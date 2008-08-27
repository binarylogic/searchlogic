module BinaryLogic
  module Searchgasm
    module Searcher
      class Base
        include ClassInheritableAttributes
        include ActiveSupport::Memoizable::Freezable
        
        attr_accessor :find_options
    
        class << self
          # Attributes
          #----------------------------------------------------------
          def associations
            @associations ||= add_associations!
          end
          
          def columns
            @columns ||= searched_class.columns
          end
          
          def columns_hash
            @columns_hash ||= searched_class.columns_hash
          end
          
          def conditions
            @conditions ||= add_conditions_for_columns!
          end
          
          def conditions_hash
            return @conditions_hash unless @conditions_hash.nil?
            @conditions_hash = {}
            conditions.each { |condition| @conditions_hash[condition.name] = condition }
            @conditions_hash
          end
          
          def primary_key
            @primary_key ||= searched_class.primary_key
          end
      
          def table_name
            @table_name ||= searched_class.table_name
          end
          
          # Actions
          #----------------------------------------------------------
          def add_condition(options = {})
            condition = Condition.new(options[:column_name], options[:condition], options[:type], searched_class)

            if !condition.column_name.blank? && condition.type == :datetime && !Time.zone.nil? && !searched_class.skip_time_zone_conversion_for_attributes.include?("#{searched_class.name.underscore}_#{condition.column_name}".to_sym)
              class_eval <<-SRC
                def #{condition.name}
                  time = read_attribute(:#{condition.name})
                  (time.blank? || time.zone != "UTC") ? time : time.in_time_zone
                end
              SRC
            else
              class_eval <<-SRC
                def #{condition.name}
                  read_attribute :#{condition.name}
                end
              SRC
            end

            class_eval <<-SRC
              def #{condition.name}=(value)
                write_attribute :#{condition.name}, value
              end
            SRC

            alias_conditions = []
            case condition.condition
            when :equals
              alias_conditions += ["", :is]
            when :does_not_equal
              alias_conditions << :is_not
            when :begins_with
              alias_conditions << :starts_with
            when :contains
              alias_conditions << :like
            when :greater_than
              alias_conditions << :gt
              alias_conditions << :after if [:datetime, :timestamp, :time, :date].include?(condition.type)
            when :greater_than_or_equal_to
              alias_conditions + [:at_least, :gte]
            when :less_than
              alias_conditions << :lt
              alias_conditions << :before if [:datetime, :timestamp, :time, :date].include?(condition.type)
            when :less_than_or_equal_to
              alias_conditions += [:at_most, :lte]
            end

            unless alias_conditions.blank?
              alias_conditions.each do |alias_condition_name|
                alias_condition = Condition.new(condition.column_name, alias_condition_name, condition.type, condition.searched_class)
                class_eval <<-SRC
                  alias_method :#{alias_condition.name}=, :#{condition.name}=
                  alias_method :#{alias_condition.name}, :#{condition.name}
                SRC
              end
            end

            condition
          end
          
          def add_conditions_for_column(name, type)
            condition_names = [:equals, :does_not_equal]
            case type
            when :string, :text
              condition_names += [:begins_with, :contains, :keywords, :ends_with]
            when :integer, :float, :decimal, :datetime, :timestamp, :time, :date
              condition_names += [:greater_than, :greater_than_or_equal_to, :less_than, :less_than_or_equal_to]
            end
            
            condition_names.collect { |condition_name| add_condition(:column_name => name, :condition => condition_name, :type => type) }
          end
          
          def search(attributes = {})
            new(attributes = {}).search
          end
          
          # Utility
          #----------------------------------------------------------
          def order_find_options(methods, order_as)
            return {} if methods.blank?

            methods = [methods] unless methods.is_a?(Array)
            includes = []
            order_strs = []

            methods.each do |method|
              method_info = method.is_a?(Hash) && !method[:method].blank? ? method : {:method => method}

              if method_info[:method].is_a?(Hash)
                relationship_name = method_info[:method].keys.first
                relationship_method = method_info[:method].values.first
                relationship_class_searcher = "#{relationship_name}Searcher".camelize.constantize
                result = relationship_class_searcher.order_find_options(relationship_method, order_as)
                includes << (result[:include].blank? ? relationship_name.to_sym : {relationship_name.to_sym => result[:include]})
                order_strs << result[:order]
              elsif method_info[:method].is_a?(Array)
                result = order_find_options(method_info[:method], order_as)
                order_strs << result[:order] unless result[:order].blank?
                includes += result[:include] unless result[:include].blank?
              elsif searched_class.column_names.include?(method_info[:method])
                order_strs << "#{table_name}.#{method_info[:method]} #{order_as}"
              elsif searched_class.reflections.keys.include?(method_info[:method].to_sym)
                relationship_class = "#{method}".camelize.constantize
                relationship_class_searcher = "#{method}Searcher".camelize.constantize
                result = relationship_class_searcher.order_find_options(relationship_class_searcher.order_by, relationship_class_searcher.order_as)
                order_strs << result[:order]
                include_meth = method_info[:method].to_sym
                include_value = result[:include].blank? ? include_meth : {include_meth => result[:include]}
                includes << include_value unless includes.include?(include_value)
              else
                #result = how_to_order(method_info[:method], order_as)
                #order_strs << result[:order] unless result[:order].blank?
                #includes << result[:include] unless result[:include].blank?
              end
            end

            {:order => order_strs.blank? ? nil : order_strs.join(", "), :include => includes.blank? ? nil : includes}
          end
          
          # Config
          #----------------------------------------------------------
          def configure
            yield self
          end
          
          def config
            config = read_inheritable_attribute(:config) || {}
            config[:order_by] ||= "#{primary_key}" unless searched_class == BinaryLogic::Searchgasm
            config[:order_as] ||= "DESC"
            config[:per_page] ||= 0
            config[:ignore_blanks] = true unless config.has_key?(:ignore_blanks)
            write_inheritable_hash(:config, config)
          end

          def order_by(value = nil)
            write_inheritable_hash(:config, config.merge(:order_by => value || config[:order_by]))
          end
          alias_method :order_by=, :order_by
          
          def order_as(value = nil)
            write_inheritable_hash(:config, config.merge(:order_as => value || config[:order_as]))
          end
          alias_method :order_as=, :order_as
          
          def per_page(value = nil)
            write_inheritable_hash(:config, config.merge(:per_page => value || config[:per_page]))
          end
          alias_method :per_page=, :per_page
          alias_method :limit, :per_page
          alias_method :limit=, :per_page
          
          def ignore_blanks(value = nil)
            write_inheritable_hash(:config, config.merge(:ignore_blanks => value || config[:ignore_blanks]))
          end
          alias_method :ignore_blanks=, :ignore_blanks
          
          def ignore_blanks?
            config[:ignore_blanks] == true
          end
          
          def searched_class(value = nil)
            @searched_class ||= value || name.scan(/(.*)Searcher/)[0][0].constantize
          end
          alias_method :searching, :searched_class
          
          # Hooks
          #----------------------------------------------------------
          def before_build_find_options(*args)
            @before_build_find_options ||= []
            @before_build_find_options += args
            @before_build_find_options.uniq!
            @before_build_find_options
          end
      
          def after_build_find_options(*args)
            @after_build_find_options ||= []
            @after_build_find_options += args
            @after_build_find_options.uniq!
            @after_build_find_options
          end
      
          def before_search(*args)
            @before_search ||= []
            @before_search += args
            @before_search.uniq!
            @before_search
          end
      
          def after_search(*args)
            @after_search ||= []
            @after_search += args
            @after_search.uniq!
            @after_search
          end
          
          private
            # Actions
            #----------------------------------------------------------
            def add_associations!
              associations = []

              (searched_class.reflect_on_all_associations).each do |association|
                next if association.options[:polymorphic]

                name = association.name
                associations << name

                class_eval <<-SRC
                  def #{name}
                    @#{name} ||= #{name.to_s.singularize.camelize}Searcher.new
                  end

                  def #{name}_used?
                    !@#{name}.blank?
                  end
                SRC
              end
              
              associations
            end

            def add_conditions_for_columns!
              conditions = []
              columns.each { |column| conditions += add_conditions_for_column(column.name, column.type) }
              conditions << add_condition(:name => "descendent_of", :condition => :descendent_of, :type => :integer) if searched_class.respond_to?(:roots)
              conditions
            end
        end
        
        def initialize(values = {})
          self.class.conditions
          self.class.associations
          
          # Set config
          config.stringify_keys.each do |config_name, value|
            send("#{config_name}=", values.delete(config_name)) if values.has_key?(config_name)
          end
          
          # Set scope
          self.scope = values.delete(:scope) if values.has_key?(:scope)
          
          self.attributes = values
        end
        
        def attributes=(values)
          values ||= {}
          values = values.stringify_keys
          
          # Set attributes
          values.each do |attribute, value|
            next if ignore_blanks? && value == "" # this is for HTML form and they leave a field blank, if you want to search using a blank explicity call the method, dont use attributes= (ex: search.whatever =)
            if respond_to?("#{attribute}=")
              send("#{attribute}=", value)
            elsif respond_to?("#{attribute}") && (searcher = send("#{attribute}")).is_a?(::Searchgasm::Base)
              searcher.attributes = value
            end
          end
          
          attributes
        end
        
        def attributes
          @attributes ||= {}
        end
        
        def build_find_options
          self.class.before_build_find_options.each { |method| send(method) }

          # check for a primary key search
          unless send(primary_key).blank?
            self.find_options = {:conditions => ["#{table_name}.#{primary_key} = ?", send(primary_key)]}
            return find_options
          end

          self.find_options = {:include => []}
          
          attributes.each do |attribute_name, uncasted_value|
            condition = self.class.conditions_hash[attribute_name]
            next if condition.nil?
            find_options.merge_find_options!(:conditions => condition.to_conditions(send(attribute_name)))
          end
                    
          self.class.associations.each do |association|
            next unless send("#{association}_used?")
            
            association_searcher = send(association)            
            association_find_options = association_searcher.build_find_options
            association_find_options[:include] = association_find_options[:include].blank? ? [association] : {association => association_find_options[:include]}
            find_options.merge_find_options!(association_find_options)
          end

          self.class.after_build_find_options.each { |method| send(method) }

          find_options
        end
        
        def changed?
          !attributes.blank?
        end
        
        def conditions
          @conditions
        end
        
        def config
          @config ||= {}
          self.class.config.each { |key, val| @config[key] = val unless @config.has_key?(key) }
          @config
        end
        
        def count(options = {})
          search(options.merge(:only_count => true))
        end
        
        def deep_attributes
          attrs = attributes.dup
          self.class.associations.each do |association|
            next unless send("#{association}_used?")
            attrs.merge!(association => send(association).deep_attributes)
          end
          attrs
        end
        
        def dump
          config.stringify_keys.merge(deep_attributes)
        end
        
        def first(options = {})
          search(options.merge(:first => true))
        end
        
        def order_by
          config[:order_by]
        end
        
        def order_by=(value)
          begin
            config[:order_by] = Marshal.load(Base64.decode64(value))
          rescue Exception
            config[:order_by] = value
          end
        end
        
        def order_as
          config[:order_as]
        end
        
        def order_as=(value)
          value = value.to_s.upcase
          return if value != "ASC" && value != "DESC"
          config[:order_as] = value
        end
        
        def per_page
          value = config[:per_page].to_i
          return 0 if value < 0
          value
        end
        alias_method :limit, :per_page
        
        def per_page=(value)
          config[:per_page] = value
        end
        alias_method :limit=, :per_page=
        
        def page
          value = config[:page].to_i
          return if value < 0
          value
        end
        
        def page=(value)
          config[:page] = value
        end
        
        def primary_key
          self.class.primary_key
        end
        
        def ignore_blanks?
          config[:ignore_blanks] == true
        end
        
        def ignore_blanks=(value)
          config[:ignore_blanks] = value
        end
        
        def scope
          @scope ||= self.class.searched_class
        end
        
        def scope=(value)
          @scope = value
        end
        
        def search(options = {})
          self.class.before_search.each { |method| send(method) }
          
          build_find_options
          
          # paginate
          if per_page > 0
            find_options[:limit] = per_page
            find_options[:offset] = page <= 0 ? 0 : (per_page * (page - 1))
          end
    
          # order
          find_options.merge_find_options!(self.class.order_find_options(order_by, order_as))
      
          # find
          find_options.merge_find_options!(options[:find_options]) unless options[:find_options].blank?
          
          count = nil
          if options[:with_count] || options[:only_count]
            count_find_options = find_options.clone
            [:limit, :offset, :from, :order].each { |key| count_find_options.delete(key) }
            
            count = scope.count(count_find_options)
            return count if options[:only_count]
          end
                    
          results = scope.find(options[:first] ? :first : :all, find_options)
          
          result = count.nil? ? results : [results, count]
          
          self.class.after_search.each { |method| send(method) }
      
          return result
        end
        
        alias_method :all, :search
        
        def searched_class
          self.class.searched_class
        end
        
        def table_name
          self.class.table_name
        end
        
        private
          def write_attribute(attribute_name, value)
            attribute_name = attribute_name.to_s
            condition = self.class.conditions_hash[attribute_name]
            value = condition.type_cast(value) if !condition.blank?
            @attributes ||= {}
            @attributes[attribute_name.to_s] = value
          end
    
          def read_attribute(attribute_name)
            attribute_name = attribute_name.to_s
            if !(value = attributes[attribute_name]).nil?
              if condition = self.class.conditions_hash[attribute_name]
                condition.type_cast(value)
              else
                value
              end
            else
              nil
            end
          end
      end
    end
  end
end

Searchgasm = BinaryLogic::Searchgasm::Searcher # to keep the class name shorter