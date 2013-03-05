require File.dirname(__FILE__) + '/aliases.rb'
module Searchlogic
  module ScopeReflectionExt
    module MatchAlias
      def convert_alias(method, value = nil)
        self.method = method.to_s == "order" ? value : method
        return self.method if match_alias.nil?
        alias_name = match_alias[1]
        replacement_value = alias_hash.find{|method, alias_array| alias_array.include?(alias_name)}.first.to_s
        replace_method(replacement_value)
      end

      def match_alias(method_name = self.method)
        return nil if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method_name})
        /(#{aliases.sort_by(&:size).reverse.join("|")})$/.match(method_name)
      end

      def replace_method(value)
        method.to_s.gsub(/(#{aliases.join("|")})$/, value)
      end
    end
  end
end
