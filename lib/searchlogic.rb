require "searchlogic/core_ext/proc"
require "searchlogic/core_ext/object"
require "searchlogic/active_record/consistency"
require "searchlogic/active_record/named_scopes"
require "searchlogic/named_scopes/conditions"
require "searchlogic/named_scopes/ordering"
require "searchlogic/named_scopes/association_conditions"
require "searchlogic/named_scopes/association_ordering"
require "searchlogic/named_scopes/alias_scope"
require "searchlogic/named_scopes/or_conditions"
require "searchlogic/search"

Proc.send(:include, Searchlogic::CoreExt::Proc)
Object.send(:include, Searchlogic::CoreExt::Object)

module ActiveRecord # :nodoc: all
  class Base
    class << self; include Searchlogic::ActiveRecord::Consistency; end
  end
end

ActiveRecord::Base.extend(Searchlogic::ActiveRecord::NamedScopes)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Conditions)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::AssociationConditions)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::AssociationOrdering)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::Ordering)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::AliasScope)
ActiveRecord::Base.extend(Searchlogic::NamedScopes::OrConditions)
ActiveRecord::Base.extend(Searchlogic::Search::Implementation)

# Try to use the search method, if it's available. Thinking sphinx and other plugins
# like to use that method as well.
if !ActiveRecord::Base.respond_to?(:search)
  ActiveRecord::Base.class_eval { class << self; alias_method :search, :searchlogic; end }
end

if defined?(ActionController)
  require "searchlogic/rails_helpers"
  ActionController::Base.helper(Searchlogic::RailsHelpers)
end