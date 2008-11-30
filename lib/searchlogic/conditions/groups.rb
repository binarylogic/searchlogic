module Searchlogic
  module Conditions
    # = Groups
    #
    # Allows you to group conditions, similar to how you would group conditions with parenthesis in an SQL statement. See the "Group conditions" section in the READM for examples.
    module Groups
      def self.included(klass)
        klass.class_eval do
        end
      end
      
      # Creates a new group object to set condition off of. See examples at top of class on how to use this.
      def group(conditions = nil, forward_arrays = false, &block)
        if conditions.is_a?(Array) && !forward_arrays
          group_objects = []
          conditions.each { |condition| group_objects << group(condition, true, &block) }
          group_objects
        else
          obj = self.class.new
          obj.conditions = conditions unless conditions.nil?
          yield obj if block_given?
          objects << obj
          obj
        end
      end
      alias_method :group=, :group
      
      def and_group(*args, &block)
        obj = group(*args, &block)
        case obj
        when Array
          obj.each { |o| o.group_any = false }
        else
          obj
        end
      end
      alias_method :and_group=, :and_group
      
      def or_group(*args, &block)
        obj = group(*args, &block)
        case obj
        when Array
          obj.each { |o| o.group_any = true }
        else
          obj
        end
      end
      alias_method :or_group=, :or_group
      
      def explicit_any=(value) # :nodoc:
        @explicit_any = value
      end
      
      def explicit_any # :nodoc
        @explicit_any
      end
      
      def explicit_any? # :nodoc:
        ["true", "1", "yes"].include? explicit_any.to_s
      end
      
      private
        def group_objects
          objects.select { |object| group?(object) }
        end
        
        def group?(object)
          object.class == self.class
        end
    end
  end
end