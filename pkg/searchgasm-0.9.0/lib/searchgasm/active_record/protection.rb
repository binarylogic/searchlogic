module BinaryLogic
  module Searchgasm
    module ActiveRecord
      module Protection
        def self.included(klass)
          klass.class_eval do
            alias_method :new_search, :build_search
            alias_method :findwp, :find_with_protection
            alias_method :allwp, :all_with_protection
            alias_method :firstwp, :first_with_protection
          end
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