module Searchlogic
  # A class that acts like a model, creates attr_accessors for named_scopes, and then
  # chains together everything when an "action" method is called. It basically makes
  # implementing search forms in your application effortless:
  #
  #   search = User.search
  #   search.username_like = "bjohnson"
  #   search.all
  #
  # Is equivalent to:
  #
  #   User.search(:username_like => "bjohnson").all
  #
  # Is equivalent to:
  #
  #   User.username_like("bjohnson").all
  class Search
    include Base
    include Conditions
    include DateParts
    include MethodMissing
    include Scopes
    include Ordering
    include ToYaml
  end
end
