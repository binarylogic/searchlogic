require "active_record"

module ::ActiveRecord
  class Base
    class << self
       def valid_find_options
         VALID_FIND_OPTIONS
       end
    end
  end
end

require "searchgasm/search/utilities"
require "searchgasm/search/condition"
require "searchgasm/search/conditions"
require "searchgasm/search/base"
require "searchgasm/active_record/protection"
require "searchgasm/active_record/base"
require "searchgasm/active_record/associations"

Searchgasm = BinaryLogic::Searchgasm