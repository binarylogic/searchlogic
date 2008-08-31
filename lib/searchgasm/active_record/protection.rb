module BinaryLogic
  module Searchgasm
    module ActiveRecord
      module Protection
        def self.included(klass)
          klass.alias_method :new_search, :build_search
          klass.alias_method :findwp, :find_with_protection
          klass.alias_method :allwp, :all_with_protection
          klass.alias_method :firstwp, :first_with_protection
        end
        
        def find_with_protection(*args)
          options = args.extract_options!
          options.merge!(:protect => true)
          args << options
          find(*args)
        end

        def all_with_protection(*args)
          options = args.extract_options!
          options.merge!(:protect => true)
          args << options
          all(*args)
        end
  
        def first_with_protection(*args)
          options = args.extract_options!
          options.merge!(:protect => true)
          args << options
          first(*args)
        end
      end
    end
  end
end