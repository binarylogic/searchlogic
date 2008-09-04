require "active_record"

require "searchgasm/active_record/base"
require "searchgasm/active_record/associations"

# Helpers
require "searchgasm/helpers/utilities_helper"
require "searchgasm/helpers/form_helper"
require "searchgasm/helpers/order_helper"
require "searchgasm/helpers/pagination_helper"

# Core
require "searchgasm/version"
require "searchgasm/search/utilities"
require "searchgasm/search/condition"
require "searchgasm/search/conditions"
require "searchgasm/search/base"

# Regular conidtion types
require "searchgasm/search/condition_types/begins_with_condition"
require "searchgasm/search/condition_types/contains_condition"
require "searchgasm/search/condition_types/does_not_equal_condition"
require "searchgasm/search/condition_types/ends_with_condition"
require "searchgasm/search/condition_types/equals_condition"
require "searchgasm/search/condition_types/greater_than_condition"
require "searchgasm/search/condition_types/greater_than_or_equal_to_condition"
require "searchgasm/search/condition_types/keywords_condition"
require "searchgasm/search/condition_types/less_than_condition"
require "searchgasm/search/condition_types/less_than_or_equal_to_condition"

# Tree condition types
require "searchgasm/search/condition_types/tree_condition"
require "searchgasm/search/condition_types/child_of_condition"
require "searchgasm/search/condition_types/descendant_of_condition"
require "searchgasm/search/condition_types/inclusive_descendant_of_condition"
require "searchgasm/search/condition_types/sibling_of_condition"

Searchgasm = BinaryLogic::Searchgasm::Search