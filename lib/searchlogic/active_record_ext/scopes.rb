require 'active_record'
Dir[File.dirname(__FILE__) + '/scopes/*.rb'].each { |f| require(f) }
module Searchlogic
  module ActiveRecordExt
    module Scopes
      def self.included(klass)
        klass.instance_eval do 
          extend Conditions
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Searchlogic::ActiveRecordExt::Scopes)
