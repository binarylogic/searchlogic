module Searchgasm
  module Shared
    # = Searchgasm Searching
    #
    # Implements searching functionality for searchgasm. Searchgasm::Search::Base and Searchgasm::Conditions::Base can both search and include
    # this module.
    module Searching
      # Use these methods just like you would in ActiveRecord
      SEARCH_METHODS = [:all, :find, :first]
      CALCULATION_METHODS = [:average, :calculate, :count, :maximum, :minimum, :sum]
      
      # Setup methods for searching
      SEARCH_METHODS.each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            options = args.extract_options!
            klass.send(:with_scope, :find => options) do
              args << (self.class < Searchgasm::Conditions::Base ? {:conditions => sanitize} : sanitize)
              klass.#{method}(*args)
            end
          end
        end_eval
      end
      
      # Setup methods for calculating
      CALCULATION_METHODS.each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            options = args.extract_options!
            klass.send(:with_scope, :find => options) do
              find_options = (self.class < Searchgasm::Conditions::Base ? {:conditions => sanitize} : sanitize)
              find_options.delete(:select)
              find_options.delete(:limit)
              find_options.delete(:offset)
              args << find_options
              klass.#{method}(*args)
            end
          end
        end_eval
      end
    end
  end
end