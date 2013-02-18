require 'active_record'
require "searchlogic/search/base"
require "searchlogic/search/method_missing"

Dir[File.dirname(__FILE__) + '/searchlogic/*.rb'].each { |f| require(f) }
module Searchlogic
  def self.included(klass)
    klass.class_eval do 
      extend Conditions
      extend Search
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic)

