module Searchlogic
  module ScopeReflectionExt
    module SearchlogicConditions
      
      def match_alias(method_name = self.method)
        return nil if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method_name})
        /(#{aliases.sort_by(&:size).reverse.join("|")})$/.match(method_name)
      end

      def searchlogic_methods
        ##Assign a method on acitve Rcord
        ## Define method on Conditions => condition then knows about all of it's subclasses
        #Searchlogic::ActiveRecordExt::Scopes::Conditions::Condition.all_matchers
        ActiveRecord::Base.all_matchers
      end

      def recognized_scopes
        searchlogic_methods + aliases
      end

    end
  end
end