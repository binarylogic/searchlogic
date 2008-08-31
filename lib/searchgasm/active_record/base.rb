module BinaryLogic
  module Searchgasm
    module ActiveRecord
      module Base
        def self.included(klass)
          klass.alias_method :new_search, :build_search
          klass.include Protection
        end
        
        def calculate_with_searchgasm(*args)
          options = args.extract_options!
          options = sanitize_options_with_searchgasm(options)
          args << options
          calculate_without_searchgasm(*args)
        end
        
        def find_every_with_searchgasm(*args)
          options = args.extract_options!
          options = sanitize_options_with_searchgasm(options)
          args << options
          find_every_without_searchgasm(options)
        end
        
        def scope_with_searchgasm(method, key = nil)
          scope = scope_without_searchgasm(method, key)
          return sanitize_options_with_searchgasm(scope) if key.nil? && method == :find
          scope
        end
        
        def build_search(options = {})
          searcher = searchgasm_searcher(options)
          yield searcher if block_given?
          searcher
        end
        
        private
          def sanitize_options_with_searchgasm(options)
            searchgasm_searcher(options).sanitize
          end
        
          def searchgasm_searcher(options)
            BinaryLogic::Searchgasm::Search::Base.new(self, options)
          end
      end
    end
  end
end

ActiveRecord::Base.send(:extend, BinaryLogic::Searchgasm::ActiveRecord::Base)

module ::ActiveRecord
  class Base
    class << self
       alias_method_chain :calculate, :searchgasm
       alias_method_chain :find_every, :searchgasm
       alias_method_chain :scope, :searchgasm
    end
  end
end