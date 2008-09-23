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
      
      def self.included(klass)
        klass.class_eval do
          attr_accessor :scope
        end
      end
      
      (SEARCH_METHODS + CALCULATION_METHODS).each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            find_options = {}
            options = args.extract_options!
            with_scopes = [scope, (self.class < Searchgasm::Conditions::Base ? {:conditions => sanitize} : sanitize(#{SEARCH_METHODS.include?(method)})), options].compact
            with_scopes.each do |with_scope|
              klass.send(:with_scope, :find => find_options) do
                klass.send(:with_scope, :find => with_scope) do
                  find_options = klass.send(:scope, :find)
                end
              end
            end
            
            if self.class < Searchgasm::Search::Base
              (find_options.symbolize_keys.keys - #{SEARCH_METHODS.include?(method) ? "Search::Base::AR_FIND_OPTIONS" : "Search::Base::AR_CALCULATIONS_OPTIONS"}).each { |option| find_options.delete(option) }
            end
            
            args << find_options
            klass.#{method}(*args)
          end
        end_eval
      end
    end
  end
end