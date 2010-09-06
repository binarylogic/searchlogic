module Searchlogic
  class Search
    module DateParts
      def conditions=(values)
        values.clone.each do |condition, value|
          # if a condition name ends with "(1i)", assume it's date / datetime
          if condition =~ /(.*)\(1i\)$/
            date_scope_name = $1
            date_parts = (1..6).to_a.map do |idx|
              values.delete("#{ date_scope_name }(#{ idx }i)")
            end.reject{|s| s.blank? }.map{|s| s.to_i }

            # did we get enough info to build a time?
            if date_parts.length >= 3
              values[date_scope_name] = Time.zone.local(*date_parts)
            end
          end
        end
        super
      end
    end
  end
end