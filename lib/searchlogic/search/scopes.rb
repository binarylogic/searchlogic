module Searchlogic
  class Search
    module Scopes
      private
        def scope_name(condition_name)
          condition_name && normalize_scope_name(condition_name)
        end

        def scope?(scope_name)
          klass.scopes.key?(scope_name) || klass.condition?(scope_name)
        end

        def scope_options(name)
          klass.send(name, nil) if !klass.respond_to?(name) # We need to set up the named scope if it doesn't exist, so we can get a value for named_scope_options
          klass.named_scope_options(name)
        end
    end
  end
end