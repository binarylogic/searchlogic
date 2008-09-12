module Searchgasm
  module ActiveRecord
    # = Searchgasm ActiveRecord Base
    # Adds in base level functionality to ActiveRecord
    module Base
      # This is an alias method chain. It hook into ActiveRecord's "calculate" method and checks to see if Searchgasm should get involved.
      def calculate_with_searchgasm(*args)
        options = args.extract_options!
        options = sanitize_options_with_searchgasm(options)
        args << options
        calculate_without_searchgasm(*args)
      end
      
      # This is an alias method chain. It hooks into ActiveRecord's "find" method and checks to see if Searchgasm should get involved.
      def find_with_searchgasm(*args)
        options = args.extract_options!
        options = sanitize_options_with_searchgasm(options)
        args << options
        find_without_searchgasm(*args)
      end
    
      # This is an alias method chain. It hooks into ActiveRecord's scopes and checks to see if Searchgasm should get involved. Allowing you to use all of Searchgasms conditions and tools
      # in scopes as well.
      #
      # === Examples
      #
      #   named_scope :top_expensive, :conditions => {:total_gt => 1_000_000}, :per_page => 10
      #
      #   with_scope(:find => {:conditions => {:total_gt => 1_000_000}, :per_page => 10}) do
      #     find(:all)
      #   end
      def scope_with_searchgasm(method, key = nil)
        scope = scope_without_searchgasm(method, key)
        return sanitize_options_with_searchgasm(scope) if key.nil? && method == :find && !scope.blank?
        scope
      end
      
      # This is a special method that Searchgasm adds in. It returns a new conditions object on the model. So you can search by conditions *only*.
      #
      # <b>This method is "protected". Meaning it checks the passed options for SQL injections. So trying to write raw SQL in *any* of the option will result in a raised exception. It's safe to pass a params object when instantiating.</b>
      #
      # === Examples
      #
      #   conditions = User.new_conditions
      #   conditions.first_name_contains = "Ben"
      #   conditions.all # can call any search method: first, find(:all), find(:first), sum("id"), etc...
      def build_conditions(values = {}, &block)
        conditions = searchgasm_conditions
        conditions.protect = true
        conditions.conditions = values
        yield conditions if block_given?
        conditions
      end
      
      # See build_conditions. This is the same method but *without* protection. Do *NOT* pass in a params object to this method.
      def build_conditions!(values = {}, &block)
        conditions = searchgasm_conditions(values)
        yield conditions if block_given?
        conditions
      end
      
      # This is a special method that Searchgasm adds in. It returns a new search object on the model. So you can search via an object.
      #
      # <b>This method is "protected". Meaning it checks the passed options for SQL injections. So trying to write raw SQL in *any* of the option will result in a raised exception. It's safe to pass a params object when instantiating.</b>
      #
      # This method has an alias "new_search"
      #
      # === Examples
      #
      #   search = User.new_search
      #   search.conditions.first_name_contains = "Ben"
      #   search.per_page = 20
      #   search.page = 2
      #   search.order_by = {:user_group => :name}
      #   search.all # can call any search method: first, find(:all), find(:first), sum("id"), etc...
      def build_search(options = {}, &block)
        search = searchgasm_searcher
        search.protect = true
        search.options = options
        yield search if block_given?
        search
      end
      
      # See build_search. This is the same method but *without* protection. Do *NOT* pass in a params object to this method.
      #
      # This also has an alias "new_search!"
      def build_search!(options = {}, &block)
        search = searchgasm_searcher(options)
        yield search if block_given?
        search
      end
      
      # Similar to ActiveRecord's attr_protected, but for conditions. It will block any conditions in this array that are being mass assigned. Mass assignments are:
      #
      # === Examples
      #
      # search = User.new_search(:conditions => {:first_name_like => "Ben", :email_contains => "binarylogic.com"})
      # search.options = {:conditions => {:first_name_like => "Ben", :email_contains => "binarylogic.com"}}
      #
      # If first_name_like is in the list of conditions_protected then it will be removed from the hash.
      def conditions_protected(*conditions)
        write_inheritable_attribute(:conditions_protected, Set.new(conditions.map(&:to_s)) + (protected_conditions || []))
      end

      def protected_conditions # :nodoc:
        read_inheritable_attribute(:conditions_protected)
      end
      
      # This is the reverse of conditions_protected. You can specify conditions here and *only* these conditions will be allowed in mass assignment. Any condition not specified here will be blocked.
      def conditions_accessible(*conditions)
        write_inheritable_attribute(:conditions_accessible, Set.new(conditions.map(&:to_s)) + (protected_conditions || []))
      end

      def accessible_conditions # :nodoc:
        read_inheritable_attribute(:conditions_accessible)
      end
    
      private
        def sanitize_options_with_searchgasm(options = {})
          return options unless Searchgasm::Search::Base.needed?(self, options)
          search = searchgasm_searcher(options)
          search.acting_as_filter = true
          search.sanitize
        end
      
        def searchgasm_conditions(options = {})
          Searchgasm::Conditions::Base.create_virtual_class(self).new(options)
        end
      
        def searchgasm_searcher(options = {})
          Searchgasm::Search::Base.create_virtual_class(self).new(options)
        end
    end
  end
end

ActiveRecord::Base.send(:extend, Searchgasm::ActiveRecord::Base)

module ActiveRecord #:nodoc: all
  class Base
    class << self
      alias_method_chain :calculate, :searchgasm
      alias_method_chain :find, :searchgasm
      alias_method_chain :scope, :searchgasm
      alias_method :new_conditions, :build_conditions
      alias_method :new_conditions!, :build_conditions!
      alias_method :new_search, :build_search
      alias_method :new_search!, :build_search!
      
      def valid_find_options
         VALID_FIND_OPTIONS
       end
    end
  end
end