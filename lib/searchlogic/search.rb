require Dir[File.dirname(__FILE__) + '/search/base.rb'].first
Dir[File.dirname(__FILE__) + '/search/*.rb'].each { |f| require(f) }

module Searchlogic
  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
      # alias_methos :search, :searchlogic
    end
  end

  module ClassMethods
    def searchlogic(condition = {})      
      Search.new(self, condition)
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic)
