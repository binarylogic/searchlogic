Dir[File.dirname(__FILE__) + '/search_ext/*.rb'].each { |f| require(f) }
module Searchlogic
  module SearchExt
    def self.included(klass)
      klass.class_eval do
        include Base
        include Attributes
        include AuthorizedScopes
        include Delegate
        include ReaderWriter
        include MethodMissing
        include Methods
      end
    end
  end
end