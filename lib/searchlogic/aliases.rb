module Searchlogic
  class Aliases
    def scope
      if self.class.match_alias(method_name)
        case alias_used
        when "_eq", "_is", "_equal"
          replace_and_send("_equals")
        when  "_not_equal_to", "_is_not", "_not", "_ne"
          replace_and_send("_does_not_equal")
        when "_lt", "_before"
          replace_and_send("_less_than")
        when "_lte", "_less_than_or_equal"
          replace_and_send("_less_than_or_equal_to")
        when "_gt", "_after"
          replace_and_send("_greater_than")
        when "_gte", "_greater_than_or_equal"
          replace_and_send("_greater_than_or_equal_to")
        when "_contains", "_includes", "_has"
          replace_and_send("_like")
        when "_does_not_include" 
          replace_and_send("_not_like")
        when "_bw" 
          replace_and_send("_begins_with")
        when "_not_begin_with"
          replace_and_send("_does_not_begin_with")
        when "_ew"
          replace_and_send("_ends_with")
        when "_not_end_with" 
          replace_and_send("_does_not_end_with")
        when "_nil"
          replace_and_send("_null")
        when "_not_nil"
          replace_and_send("_not_null")
        when "_present"
          replace_and_send("_not_blank")
        end
      end
    end

    def self.match_alias(method)
        /(_is|_eq|_not_equal_to|_is_not|_not|_ne|_lt|_before|_less_than_or_equal|_greater_than_or_equal|_lte|_gt|_after|_gte|_contains|_includes|_does_not_include|_bw|_not_begin_with|_ew|_not_end_with|_nil|_not_nil|_present)$/.match(method)
    end

    private

      def replace_and_send(method)
        method = method_name.to_s.gsub(alias_used, method)
        klass.send(method, value)
      end
      def alias_used
        self.class.match_alias(method_name)[0]
      end
  end
end
