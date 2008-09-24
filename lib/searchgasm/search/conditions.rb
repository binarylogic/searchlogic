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
          alias_method_chain :conditions, :conditions
          alias_method_chain :auto_joins, :conditions
          alias_method_chain :joins, :conditions
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
        @memoized_auto_joins = nil
        case values
        when Searchgasm::Conditions::Base
          @conditions = values
        else
          @conditions.conditions = values
        end
      end
      
      def conditions_with_conditions
        @memoized_auto_joins = nil # have to assume they are calling a condition on a relationship
        conditions_without_conditions
      end
      
      # Tells searchgasm what relationships to join during the search. This is based on what conditions you set.
      #
      # <b>Be careful!</b>
      # ActiveRecord associations can be an SQL train wreck. Make sure you think about what you are searching and that you aren't joining a table with a million records.
      def auto_joins_with_conditions
        @memoized_auto_joins ||= merge_joins(auto_joins_without_conditions, conditions.auto_joins)
      end
      
      # Changes joins to use left outer joins if conditions.any == true.
      def joins_with_conditions
        if conditions.any?
          join_dependency = ::ActiveRecord::Associations::ClassMethods::JoinDependency.new(klass, joins_without_conditions, nil)
          join_dependency.join_associations.collect { |assoc| assoc.association_join }.join
        else
          joins_without_conditions
        end
      end
      
      def sanitize_with_conditions(searching = true) # :nodoc:
        find_options = sanitize_without_conditions(searching)
        if conditions_obj = find_options.delete(:conditions)
          new_conditions = conditions_obj.sanitize
          find_options[:conditions] = new_conditions unless new_conditions.blank?
        end
        find_options
      end
    end
  end
end