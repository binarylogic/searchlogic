module Searchlogic
  module NamedScopes
    # Adds the ability to create alias scopes that allow you to alias a named
    # scope or create a named scope procedure. See the alias_scope method for a more
    # detailed explanation.
    module AliasScope
      # In some instances you might create a class method that essentially aliases a named scope
      # or represents a named scope procedure. Ex:
      #
      #   class User
      #     def self.teenager
      #       age_gte(13).age_lte(19)
      #     end
      #   end
      #
      # This is obviously a very basic example, but notice how we are utilizing already existing named
      # scopes so that we do not have to repeat ourself. This method makes a lot more sense when you are
      # dealing with complicated named scope.
      #
      # There is a problem though. What if you want to use this in your controller's via the 'search' method:
      #
      #   User.search(:teenager => true)
      #
      # You would expect that to work, but how does Searchlogic::Search tell the difference between your
      # 'teenager' method and the 'destroy_all' method. It can't, there is no way to tell unless we actually
      # call the method, which we obviously can not do.
      #
      # The being said, we need a way to tell searchlogic that this is method is safe. Here's how you do that:
      #
      #   User.alias_scope :teenager, lambda { age_gte(13).age_lte(19) }
      #
      # This feels better, it feels like our other scopes, and it provides a way to tell Searchlogic that this
      # is a safe method.
      def alias_scope(name, options = nil)
        alias_scopes[name.to_sym] = options
        (class << self; self; end).instance_eval do
          define_method name do |*args|
            case options
            when Symbol
              send(options, *args)
            else
              options.call(*args)
            end
          end
        end
      end
      alias_method :scope_procedure, :alias_scope

      def condition?(name) # :nodoc:
        super || alias_scope?(name)
      end

      def named_scope_options(name) # :nodoc:
        super || alias_scopes[name.to_sym]
      end

      private
        def alias_scopes # :nodoc:
          read_inheritable_attribute(:alias_scopes) || write_inheritable_attribute(:alias_scopes, {})
        end

        def alias_scope?(name) # :nodoc:
          return false if name.blank?
          alias_scopes.key?(name.to_sym)
        end
    end
  end
end
