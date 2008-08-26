module BinaryLogic
  module Searchgasm
    module Searcher
      # Extend the AR Column class to get the type_casting functionality and other functionality
      # no reason to reinvent the wheel      
      class Attribute < ActiveRecord::ConnectionAdapters::Column
        attr_reader :options

        def initialize(*args)
          options = args.first.dup
          args = [options[:name], nil, options[:type] == :integer ? "int" : options[:type].to_s, true] # for calling super
          super
          @options = options
        end
      end
      
      class Base
        include ClassInheritableAttributes
        
        attr_accessor :find_options
    
        class << self
          # General
          #----------------------------------------------------------
          def add_attribute(options = {})
            options[:name] ||= "#{options[:column_name]}_#{options[:condition]}"
            
            @attributes ||= []
            @attributes << Attribute.new(options)

            if !options[:column_name].blank? && options[:type] == :datetime && !Time.zone.nil? && !searched_class.skip_time_zone_conversion_for_attributes.include?("#{searched_class.name.underscore}_#{options[:column_name]}".to_sym)
              class_eval <<-SRC
                def #{options[:name]}
                  time = read_attribute(:#{options[:name]})
                  (time.blank? || time.zone != "UTC") ? time : time.in_time_zone
                end
              SRC
            else
              class_eval <<-SRC
                def #{options[:name]}
                  read_attribute :#{options[:name]}
                end
              SRC
            end
            
            class_eval <<-SRC
              def #{options[:name]}=(value)
                write_attribute :#{options[:name]}, value
              end
            SRC
            
            alias_methods = []
            case options[:condition]
            when :equals
              alias_methods += ["", :is]
            when :does_not_equal
              alias_methods << :is_not
            when :begins_with
              alias_methods << :starts_with
            when :contains
              alias_methods << :keywords
            when :greater_than
              alias_methods << :gt
              alias_methods << :after if [:datetime, :timestamp, :time, :date].include?(options[:type])
            when :greater_than_or_equal_to
              alias_methods + [:at_least, :gte]
            when :less_than
              alias_methods << :lt
              alias_methods << :before if [:datetime, :timestamp, :time, :date].include?(options[:type])
            when :less_than_or_equal_to
              alias_methods += [:at_most, :lte]
            end
            
            unless alias_methods.blank?
              alias_methods.each do |alias_method_name|
                alias_method_full_name = "#{options[:column_name]}" + (alias_method_name.blank? ? "" : "_#{alias_method_name}")
                @attributes << Attribute.new(options.merge(:name => alias_method_full_name))
                class_eval <<-SRC
                  alias_method :#{alias_method_full_name}=, :#{options[:name]}=
                  alias_method :#{alias_method_full_name}, :#{options[:name]}
                SRC
              end
            end
            
            @attributes.last
          end
          
          def add_column(name, type)
            conditions = [:equals, :does_not_equal]
            case type
            when :string, :text
              conditions += [:begins_with, :contains, :ends_with]
            when :integer, :float, :decimal, :datetime, :timestamp, :time, :date
              conditions += [:greater_than, :greater_than_or_equal_to, :less_than, :less_than_or_equal_to]
            end
            
            conditions.each { |condition| add_attribute(:column_name => name, :condition => condition, :type => type) }
            
            true
          end
          
          def add_associations!
            unless @added_associations
              @associations ||= []
              
              (searched_class.reflect_on_all_associations).each do |association|
                next if association.options[:polymorphic]
              
                name = association.name
                @associations << name
              
                class_eval <<-SRC
                  def #{name}
                    @#{name} ||= #{name.to_s.singularize.camelize}Searcher.new
                  end
                  
                  def #{name}_used?
                    !@#{name}.blank?
                  end
                SRC
              end
              
              @added_associations = true
            end
          end
          
          def add_columns!
            unless @added_columns
              searched_class.columns.each { |column| add_column(column.name, column.type) }
              add_attribute(:name => "descendent_of", :condition => :descendent_of, :type => :integer) if searched_class.respond_to?(:roots)
              @added_columns = true
            end
          end
          
          def associations
            add_associations!
            @associations
          end
          
          def attributes
            add_columns!
            @attributes
          end
          
          def attributes_hash
            hash = {}
            attributes.each { |attribute| hash[attribute.name] = attribute }
            hash
          end
          alias_method :columns_hash, :attributes_hash # to help the searcher act like a model, good example is when calendar_date_select tries to determine the type of an attribute
          
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
          
          def primary_key
            searched_class.primary_key
          end
      
          def searched_class
            @searched_class ||= name.scan(/(.*)Searcher/)[0][0].constantize
          end
      
          def table_name
            @table_name ||= searched_class.table_name
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
          
          def ignore_blanks(value = nil)
            write_inheritable_hash(:config, config.merge(:ignore_blanks => value || config[:ignore_blanks]))
          end
          alias_method :ignore_blanks=, :ignore_blanks
          
          def ignore_blanks?
            config[:ignore_blanks] == true
          end
          
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
        end
        
        def initialize(values = {})
          self.class.add_columns!
          self.class.add_associations!
          self.attributes = values
        end
        
        def attributes=(values)
          values ||= {}
          values = values.stringify_keys

          # Set config
          config.stringify_keys.each do |config_name, value|
            send("#{config_name}=", values.delete(config_name)) if values.has_key?(config_name)
          end
          
          # Set attributes
          values.each do |attribute, value|
            next if ignore_blanks? && value == "" # this is for HTML form and they leave a field blank, if you want to search using a blank explicity call the method, dont use attributes= (ex: search.whatever =)
            if respond_to?("#{attribute}=")
              send("#{attribute}=", value)
            elsif respond_to?("#{attribute}") && (searcher = send("#{attribute}")).is_a?(::Searchgasm::Base)
              searcher.attributes = value
            end
          end
        end
        
        def attributes
          @attributes || {}
        end
        
        def build_find_options
          self.class.before_build_find_options.each { |method| send(method) }

          # check for a primary key search
          unless send(primary_key).blank?
            self.find_options = {:conditions => ["#{table_name}.#{primary_key} = ?", send(primary_key)]}
            return find_options
          end

          self.find_options = {:include => []}
          conditions_strs = []
          conditions_subs = []
          
          attributes.each do |attribute_name, uncasted_value|
            attribute_object = self.class.attributes_hash[attribute_name]
            next if attribute_object.nil?
            
            value = send(attribute_name)
            value = value.utc if value.respond_to?(:utc)
            column_name = attribute_object.options[:column_name]
            
            case attribute_object.options[:condition]
            when :equals
              if value == "nil" || value.nil?
                conditions_strs << "#{table_name}.#{column_name} is NULL"
              else
                conditions_strs << "#{table_name}.#{column_name} = ?"
                conditions_subs << value
              end
            when :does_not_equal
              if value == "nil" || value.nil?
                conditions_strs << "#{table_name}.#{column_name} is not NULL"
              else
                conditions_strs << "#{table_name}.#{column_name} != ?"
                conditions_subs << value
              end
            when :begins_with
              search_parts = value.split(/ /)
              search_parts.each do |search_part|
                conditions_strs << "#{table_name}.#{column_name} like ?"
                conditions_subs << "#{search_part}%"
              end
            when :contains
              search_parts = value.split(/ /)
              search_parts.each do |search_part|
                conditions_strs << "#{table_name}.#{column_name} like ?"
                conditions_subs << "%#{search_part}%"
              end
            when :ends_with
              search_parts = value.split(/ /)
              search_parts.each do |search_part|
                conditions_strs << "#{table_name}.#{column_name} like ?"
                conditions_subs << "%#{search_part}"
              end
            when :greater_than
              conditions_strs << "#{table_name}.#{column_name} > ?"
              conditions_subs << value
            when :greater_than_or_equal_to
              conditions_strs << "#{table_name}.#{column_name} >= ?"
              conditions_subs << value
            when :less_than
              conditions_strs << "#{table_name}.#{column_name} < ?"
              conditions_subs << value
            when :less_than_or_equal_to
              conditions_strs << "#{table_name}.#{column_name} <= ?"
              conditions_subs << value
            when :descendent_of
              root = searched_class.find(value)
              condition_strs = ["#{table_name}.#{primary_key} = ?"]
              conditions_subs << value
              root.all_children.each do |child|
                condition_strs << "#{table_name}.#{primary_key} = ?"
                conditions_subs << child.send(primary_key)
              end
              conditions_strs << condition_strs.join(" or ")
            end
          end

          find_options[:conditions] = [conditions_strs.join(options[:match_conditions] == :any ? " or " : " and "), *conditions_subs] if conditions_strs.size > 0
                    
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
        
        def per_page=(value)
          config[:per_page] = value
        end
        
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
            attribute = self.class.attributes_hash[attribute_name]
            value = attribute.type_cast(value) if !attribute.blank?
            @attributes ||= {}
            @attributes[attribute_name.to_s] = value
          end
    
          def read_attribute(attribute_name)
            attribute_name = attribute_name.to_s
            if !(value = attributes[attribute_name]).nil?
              if attribute = self.class.attributes_hash[attribute_name]
                attribute.type_cast(value)
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