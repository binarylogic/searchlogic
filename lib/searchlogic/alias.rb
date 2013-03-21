module Searchlogic
  class Alias
    attr_reader :method

    def self.convert_alias(method)
      new(method).convert_alias
    end

    def self.match(method)
      new(method).match
    end

    def initialize(method)
      @method = method 
    end

    def match
      /(#{aliases.sort_by(&:size).reverse.join("|")})$/.match(method) || /(#{aliases.sort_by(&:size).reverse.join("|")})(_any|_all)$/.match(method)
    end

    def convert_alias
      return method if match.nil?
      alias_name = match[1]
      replacement_value = alias_hash.find{|method, alias_array| alias_array.include?(alias_name)}.first.to_s
      method.to_s.gsub(/#{alias_name}(_|$)/, replacement_value + "_").gsub(/_$/, "")
    end

    def aliases
      alias_hash.collect{|k,v| v }.flatten
    end

    ##Leading underscore indicates that the condition is expected at the end of the method, important for replaceing aliases
    def alias_hash
      {
        :_not_blank => %w{_present},
        :_equals => %w{_eq _is _equal _in},
        :_does_not_equal => %w{_not_equal_to _is_not _not _ne _not_equal _not_in},
        :_less_than => %w{_lt _before},
        :_greater_than => %w{_gt _after},
        :_less_than_or_equal_to =>  %w{_lte _less_than_or_equal},
        :_greater_than_or_equal_to => %w{_gte _greater_than_or_equal},
        :_not_like => %w{_does_not_include},
        :_like => %w{_contains _includes _has},
        :_begins_with => %w{_bw},
        :_does_not_begin_with => %w{_not_begin_with},
        :_ends_with => %w{_ew},
        :_does_not_end_with =>  %w{_not_end_with},
        :_null => %w{_nil},
        :_not_null => %w{_not_nil},
      }
    end
  end
end