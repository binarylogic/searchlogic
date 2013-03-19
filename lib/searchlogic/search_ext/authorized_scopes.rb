module Searchlogic
  module SearchExt
    module AuthorizedScopes
    
      private
        
        def associated_column?(method)
          !!(klass.reflect_on_all_associations.detect{|associaton| method.to_s.include?(associaton.name.to_s)})
        end
    end
  end
end