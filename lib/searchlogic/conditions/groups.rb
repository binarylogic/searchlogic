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
      def group(&block)
        obj = self.class.new
        yield obj if block_given?
        objects << obj
        obj
      end
      
      # Lets you conditions to be groups or an array of conditions to be put in their own group. Each item in the array will create a new group. This is nice for using
      # groups in forms.
      def group=(value)
        case value
        when Array
          value.each { |v| group.conditions = v }
        else
          group.conditions = value
        end
      end
      
      private
        def group_objects
          objects.select { |object| object.class == self.class }
        end
    end
  end
end