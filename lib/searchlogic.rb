require 'active_record'
Dir[File.dirname(__FILE__) + '/searchlogic/*.rb'].each { |f| require(f) }

module Searchlogic
  def self.included(klass)
    klass.class_eval do 
      extend Conditions
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic)
