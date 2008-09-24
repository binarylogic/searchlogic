module Searchgasm
  module Search
    # = Searchgasm Searching
    #
    # Implements searching functionality for searchgasm. Searchgasm::Search::Base and Searchgasm::Conditions::Base can both search and include
    # this module.
    module Searching
      # Use these methods just like you would in ActiveRecord
      SEARCH_METHODS = [:all, :find, :first]
      CALCULATION_METHODS = [:average, :calculate, :count, :maximum, :minimum, :sum]
      
      def self.included(klass)
        klass.class_eval do
          attr_accessor :scope
        end
      end
      
      (SEARCH_METHODS + CALCULATION_METHODS).each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            find_options = {}
            options = args.extract_options! # can't pass options, your options are in the search
            klass.send(:with_scope, :find => scope) do
              args << sanitize(#{SEARCH_METHODS.include?(method)})
              klass.#{method}(*args)
            end
          end
        end_eval
      end
    end
  end
end