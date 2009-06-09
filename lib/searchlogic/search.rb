module Searchlogic
  module Search
    def named_scope_options(name)
      key = nil
      if details = alias_condition_details(name)
        key = "#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
      else
        key = name.to_sym
      end
      
      eval("options", scopes[key])
    end
    
    # The arity for a named scope's proc is important, because we use the arity
    # to determine if the condition should be ignored when calling the search method.
    # If the condition is false and the arity is 0, then we skip it all together. Ex:
    #
    #   User.named_scope :age_is_4, :conditions => {:age => 4}
    #   User.search(:age_is_4 => false) == User.all
    #   User.search(:age_is_4 => true) == User.all(:conditions => {:age => 4})
    #
    # We also use it when trying to "copy" the underlying named scope for association
    # conditions.
    def named_scope_arity(name)
      options = named_scope_options(name)
      options.respond_to?(:arity) ? options.arity : nil
    end
    
    def search(conditions = {})
      SearchProxy.new(self, scope(:find), conditions)
    end
  end
end