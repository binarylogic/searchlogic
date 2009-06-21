module Searchlogic
  module NamedScopes
    # Adds the ability to create alias scopes that allow you to alias a named
    # scope or create a named scope procedure, while at the same time letting
    # Searchlogic know that this is a safe method.
    module AliasScope
      # The searchlogic Search class takes a hash and chains the values together as named scopes.
      # For security reasons the only hash keys that are allowed must be mapped to named scopes.
      # You can not pass the name of a class method and expect that to be called. In some instances
      # you might create a class method that essentially aliases a named scope or represents a
      # named scope procedure. Ex:
      #
      #   User.named_scope :teenager, :conditions => ["age >= ? AND age <= ?", 13, 19]
      #
      # This is obviously a very basic example, but there is logic that is duplicated here. For
      # more complicated named scopes this might make more sense, but to make my point you could
      # do something like this instead
      #
      #   class User
      #     def teenager
      #       age_gte(13).age_lte(19)
      #     end
      #   end
      #
      # As I stated above, you could not use this method with the Searchlogic::Search class because
      # there is no way to tell that this is actually a named scope. Instead, Searchlogic lets you
      # do something like this:
      #
      #   User.alias_scope :teenager, lambda { age_gte(13).age_lte(19) }
      #
      # It fits in better, at the same time Searchlogic will know this is an acceptable named scope.
      def alias_scope(name, options = nil)
        alias_scopes[name.to_sym] = options
        (class << self; self end).instance_eval do
          define_method name do |*args|
            case options
            when Symbol
              send(options)
            else
              options.call(*args)
            end
          end
        end
      end
      
      def alias_scopes # :nodoc:
        @alias_scopes ||= {}
      end
      
      def alias_scope?(name) # :nodoc:
        alias_scopes.key?(name.to_sym)
      end
      
      def condition?(name) # :nodoc:
        super || alias_scope?(name)
      end
      
      def named_scope_options(name) # :nodoc:
        super || alias_scopes[name.to_sym]
      end
    end
  end
end