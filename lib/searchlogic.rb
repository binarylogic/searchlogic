require "searchlogic/named_scopes/conditions"
require "searchlogic/named_scopes/ordering"
require "searchlogic/named_scopes/associations"
require "searchlogic/search"
require "searchlogic/search_proxy"

ActiveRecord::Base.extend(Searchlogic::NamedScopes::Conditions)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Ordering)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Associations)