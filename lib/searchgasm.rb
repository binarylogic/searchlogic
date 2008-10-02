$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require "active_record"
require "active_record/version"
require "active_record/connection_adapters/mysql_adapter"
require "active_record/connection_adapters/postgresql_adapter"
require "active_record/connection_adapters/sqlite_adapter"
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
require "searchgasm/active_record/connection_adapters/mysql_adapter"
require "searchgasm/active_record/connection_adapters/postgresql_adapter"
require "searchgasm/active_record/connection_adapters/sqlite_adapter"

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
require "searchgasm/condition/tree"
SEARCHGASM_CONDITIONS = [:begins_with, :blank, :child_of, :descendant_of, :ends_with, :equals, :greater_than, :greater_than_or_equal_to, :inclusive_descendant_of, :like, :nil, :not_begin_with, :not_end_with, :not_equal, :not_have_keywords, :keywords, :less_than, :less_than_or_equal_to, :sibling_of]
SEARCHGASM_CONDITIONS.each { |condition| require "searchgasm/condition/#{condition}" }

# Modifiers
require "searchgasm/modifiers/base"
SEARCHGASM_MODIFIERS = [:day_of_month, :day_of_week, :day_of_year, :hour, :microseconds, :milliseconds, :minute, :month, :second, :week, :year]
SEARCHGASM_MODIFIERS.each { |modifier| require "searchgasm/modifiers/#{modifier}" }

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
    
    SEARCHGASM_CONDITIONS.each { |condition| Base.register_condition("Searchgasm::Condition::#{condition.to_s.camelize}".constantize) }
    SEARCHGASM_MODIFIERS.each { |modifier| Base.register_modifier("Searchgasm::Modifiers::#{modifier.to_s.camelize}".constantize) }
  end
  
  # The namespace I put all cached search classes.
  module Cache
  end
end