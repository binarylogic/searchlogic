require 'searchlogic/search/search'
Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
require 'pry'
module Searchlogic
  module Search
    private
      def method_missing(method, *args, &block) 
        super || generate_search(method, args, &block)
      end
  end
end