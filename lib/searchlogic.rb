Dir[File.dirname(__FILE__) + '/searchlogic/*.rb'].each { |f| require(f) }
require 'active_record'
module Searchlogic
end