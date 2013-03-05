require File.dirname(__FILE__) + '/search_ext.rb'

module Searchlogic
  class Search < BasicObject
    include SearchExt
  end
end