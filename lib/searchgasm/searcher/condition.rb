# Extend the AR Column class to get the type_casting functionality and other functionality
# no reason to reinvent the wheel
module BinaryLogic
  module Searchgasm
    module Searcher
      class Condition < ::ActiveRecord::ConnectionAdapters::Column
        attr_accessor :condition, :primary_key, :searched_class, :table_name
        attr_reader :options

        def initialize(*args)
          options = args.first.dup
          raise(ArgumentError, "You must provide the :searched_class option") if options[:searched_class].blank?

          self.condition = options[:condition]
          self.searched_class = options[:searched_class]
          self.primary_key = searched_class.primary_key
          self.table_name = searched_class.table_name
          
          args = [options[:name], nil, options[:type] == :integer ? "int" : options[:type].to_s, true] # for calling super
          super
        end
        
        def to_conditions(value)
          conditions_strs = []
          conditions_subs = []
          
          case condition
          when :equals
            if value == "nil" || value.nil?
              conditions_strs << "#{table_name}.#{name} is NULL"
            else
              conditions_strs << "#{table_name}.#{name} = ?"
              conditions_subs << value
            end
          when :does_not_equal
            if value == "nil" || value.nil?
              conditions_strs << "#{table_name}.#{name} is not NULL"
            else
              conditions_strs << "#{table_name}.#{name} != ?"
              conditions_subs << value
            end
          when :begins_with
            search_parts = value.split(/ /)
            search_parts.each do |search_part|
              conditions_strs << "#{table_name}.#{name} like ?"
              conditions_subs << "#{search_part}%"
            end
          when :contains
            search_parts = value.split(/ /)
            search_parts.each do |search_part|
              conditions_strs << "#{table_name}.#{name} like ?"
              conditions_subs << "%#{search_part}%"
            end
          when :ends_with
            search_parts = value.split(/ /)
            search_parts.each do |search_part|
              conditions_strs << "#{table_name}.#{name} like ?"
              conditions_subs << "%#{search_part}"
            end
          when :greater_than
            conditions_strs << "#{table_name}.#{name} > ?"
            conditions_subs << value
          when :greater_than_or_equal_to
            conditions_strs << "#{table_name}.#{name} >= ?"
            conditions_subs << value
          when :less_than
            conditions_strs << "#{table_name}.#{name} < ?"
            conditions_subs << value
          when :less_than_or_equal_to
            conditions_strs << "#{table_name}.#{name} <= ?"
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
          
          [conditions_strs.join(" and "), *conditions_subs]
        end
      end
    end
  end
end