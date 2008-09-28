$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require "active_record"
require "active_record/version"
require "active_support"

# Core Ext
require "searchgasm/core_ext/hash"

# Shared
require "searchgasm/shared/utilities"
require "searchgasm/shared/virtual_classes"

# Base classes
require "searchgasm/version"
require "searchgasm/config"

# ActiveRecord
require "searchgasm/active_record/base"
require "searchgasm/active_record/associations"

# Search
require "searchgasm/search/ordering"
require "searchgasm/search/pagination"
require "searchgasm/search/conditions"
require "searchgasm/search/searching"
require "searchgasm/search/base"
require "searchgasm/search/protection"

# Conditions
require "searchgasm/conditions/protection"
require "searchgasm/conditions/base"

# Condition
require "searchgasm/condition/base"
require "searchgasm/condition/begins_with"
require "searchgasm/condition/blank"
require "searchgasm/condition/contains"
require "searchgasm/condition/does_not_equal"
require "searchgasm/condition/ends_with"
require "searchgasm/condition/equals"
require "searchgasm/condition/greater_than"
require "searchgasm/condition/greater_than_or_equal_to"
require "searchgasm/condition/keywords"
require "searchgasm/condition/less_than"
require "searchgasm/condition/less_than_or_equal_to"
require "searchgasm/condition/nil"
require "searchgasm/condition/tree"
require "searchgasm/condition/child_of"
require "searchgasm/condition/descendant_of"
require "searchgasm/condition/inclusive_descendant_of"
require "searchgasm/condition/sibling_of"

# Helpers
require "searchgasm/helpers/utilities"
require "searchgasm/helpers/form"
require "searchgasm/helpers/control_types/link"
require "searchgasm/helpers/control_types/links"
require "searchgasm/helpers/control_types/select"
require "searchgasm/helpers/control_types/remote_link"
require "searchgasm/helpers/control_types/remote_links"
require "searchgasm/helpers/control_types/remote_select"

# Lets do it!
module Searchgasm
  module Search
    class Base
      include Conditions
      include Ordering
      include Protection
      include Pagination
      include Searching
    end
  end
  
  module Conditions
    class Base
      include Protection
    end
    
    [:begins_with, :blank, :child_of, :contains, :descendant_of, :does_not_equal, :ends_with, :equals, :greater_than, :greater_than_or_equal_to, :inclusive_descendant_of, :nil, :keywords, :less_than, :less_than_or_equal_to, :sibling_of].each do |condition|
      Base.register_condition("Searchgasm::Condition::#{condition.to_s.camelize}".constantize)
    end
  end
  
  # The namespace I put all cached search classes.
  module Cache
  end
end