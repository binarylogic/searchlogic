require 'active_record'
Dir[File.dirname(__FILE__) + '/searchlogic/*.rb'].each { |f| require(f) }
module Searchlogic
end