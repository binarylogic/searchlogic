module Searchgasm
  module ActiveRecord
    module ConnectionAdapters
      module MysqlAdapter
        def hour_sql
          "HOUR(?)"
        end
        
        def month_sql
          "MONTH(?)"
        end
      end
    end
  end
end