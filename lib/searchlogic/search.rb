Dir[File.dirname(__FILE__) + '/search/*.rb'].each { |f| require(f) }
module Searchlogic
  module Search
    private 
    def method_missing(method, *args, &block)
      generate_search_proxy(self, method, args) || super
    end
    def generate_search_proxy(klass, method, args)      
      return nil unless method == :search
      Search::SearchProxy.new(klass, args.first)
    end
  end 
end