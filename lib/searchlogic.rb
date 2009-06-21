require "searchlogic/core_ext/proc"
require "searchlogic/core_ext/object"
require "searchlogic/named_scopes/conditions"
require "searchlogic/named_scopes/ordering"
require "searchlogic/named_scopes/associations"
require "searchlogic/named_scopes/alias_scope"
require "searchlogic/search"

Proc.send(:include, Searchlogic::CoreExt::Proc)
Object.send(:include, Searchlogic::CoreExt::Object)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Conditions)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Ordering)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Associations)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::AliasScope)
ActiveRecord::Base.extend(Searchlogic::Search::Implementation)

if defined?(ActionController)
  require "searchlogic/rails_helpers"
  ActionController::Base.helper(Searchlogic::RailsHelpers)
end