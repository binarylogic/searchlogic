module Searchgasm
  module Search
    # = Searchgasm Conditions
    #
    # Implements all of the conditions functionality into a searchgasm search. All of this functonality is extracted out into its own class Searchgasm::Conditions::Base. This is a separate module to help keep the code
    # clean and organized.
    module Conditions
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :initialize, :conditions
          alias_method_chain :conditions=, :conditions
          alias_method_chain :include, :conditions
          alias_method_chain :sanitize, :conditions
        end
      end
      
      def initialize_with_conditions(init_options = {})
        self.conditions = Searchgasm::Conditions::Base.create_virtual_class(klass).new
        initialize_without_conditions(init_options)
      end
      
      # Sets conditions on the search. Accepts a hash or a Searchgasm::Conditions::Base object.
      #
      # === Examples
      #
      #   search.conditions = {:first_name_like => "Ben"}
      #   search.conditions = User.new_conditions
      #
      # or to set a scope
      #
      #   search.conditions = "user_group_id = 6"
      #
      # now you can create the rest of your search and your "scope" will get merged into your final SQL.
      # What this does is determine if the value a hash or a conditions object, if not it sets it up as a scope.
      def conditions_with_conditions=(values)
        
        case values
        when Searchgasm::Conditions::Base
          @conditions = values
        else
          @conditions.conditions = values
        end
      end
      
      # Tells searchgasm was relationships to include during the search. This is based on what conditions you set.
      #
      # <b>Be careful!</b>
      # ActiveRecord associations can be an SQL train wreck. Make sure you think about what you are searching and that you aren't joining a table with a million records.
      def include_with_conditions
        includes = [include_without_conditions, conditions.includes].flatten.compact.uniq
        includes.blank? ? nil : (includes.size == 1 ? includes.first : includes)
      end
      
      def sanitize_with_conditions(for_method = nil) # :nodoc:
        find_options = sanitize_without_conditions(for_method)
        find_options[:conditions] = find_options[:conditions].sanitize if find_options[:conditions]
        find_options
      end
      
      def scope # :nodoc:
        conditions.scope
      end
      
      def scope=(value) # :nodoc:
        conditions.scope = value
      end
    end
  end
end