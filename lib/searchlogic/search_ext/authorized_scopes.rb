module Searchlogic
  module SearchExt
    module AuthorizedScopes
    
      private
        def known_scopes        
          Searchlogic::ScopeReflection.recognized_scopes + klass.named_scopes.collect{|k,v| k.to_s}
        end
        
        def authorized_scope?(scope) 
          !!(known_scopes.detect{ |ks| scope.to_s.include?(ks.to_s)} || ordering?(scope))
        end
        
        def associated_column?(method)
          !!(klass.reflect_on_all_associations.detect{|associaton| method.to_s.include?(associaton.name.to_s)})
        end
    end
  end
end