module Searchlogic
  class Search
    # Responsible for adding a "search" method into your models.
    module Implementation
      # Additional method, gets aliased as "search" if that method
      # is available. A lot of other libraries like to use "search"
      # as well, so if you have a conflict like this, you can use
      # this method directly.
      def searchlogic(conditions = {})
        Search.new(self, scope(:find), conditions)
      end
    end
  end
end
