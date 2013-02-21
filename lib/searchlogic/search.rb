require Dir[File.dirname(__FILE__) + '/search/base.rb'].first
Dir[File.dirname(__FILE__) + '/search/*.rb'].each { |f| require(f) }

module Searchlogic
  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def searchlogic(conditions = {})      
      Search.new(self, conditions)
    end
    alias_method :search, :searchlogic
  end
end

ActiveRecord::Base.send(:include, Searchlogic)
