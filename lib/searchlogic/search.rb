require 'searchlogic/search/base/base'
Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
require 'pry'
module Searchlogic
  module Search
    module Base
    private
      def method_missing(method, *args, &block) 
        generate_search(method, args, &block)
      end


      def generate_search(method, args, &block)
        binding.pry
      end
    end
  end
end