require File.dirname(__FILE__) + '/scope_reflection_ext.rb'

module Searchlogic
  class ScopeReflection
    include ScopeReflectionExt
    attr_reader :klass, :method
    def initialize(method, klass = nil)
      @klass = klass
      @method = method
    end 
  end
end