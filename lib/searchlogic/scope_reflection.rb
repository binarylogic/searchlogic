require File.dirname(__FILE__) + '/scope_reflection_ext.rb'

module Searchlogic
  class ScopeReflection
    include ScopeReflectionExt
    ##Take a method, return the normalized scope and column type (optionally specify it for named scopes)
    attr_reader :klass, :method
    def initialize(klass, method)
      @klass = klass
      @method = method
    end 
  end
end