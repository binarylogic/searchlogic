module Searchgasm
  module Shared
    # = Searchgasm Searching
    #
    # Implements searching functionality for searchgasm. Searchgasm::Search::Base and Searchgasm::Conditions::Base can both search and include
    # this module.
    module Searching
      # Use these methods just like you would in ActiveRecord
      SEARCH_METHODS = [:all, :average, :calculate, :count, :find, :first, :maximum, :minimum, :sum]
      
      # Setup methods for searching
      SEARCH_METHODS.each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            options = args.extract_options!
            klass.send(:with_scope, :find => options) do
              args << sanitize(:#{method})
              klass.#{method}(*args)
            end
          end
        end_eval
      end
    end
  end
end