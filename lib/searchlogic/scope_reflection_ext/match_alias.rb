require File.dirname(__FILE__) + '/aliases.rb'
module Searchlogic
  module ScopeReflectionExt
    module MatchAlias
      def convert_alias(method, value, klass)
        self.method = method.to_s == "order" ? options[:value] : method
        return self.method if match_alias.nil? || scope_name?(method, klass)
        alias_name = match_alias[1]
        replacement_value = alias_hash.find{|method, alias_array| alias_array.include?(alias_name)}.first.to_s
        replace_method(replacement_value)
      end

      def match_alias(method_name = self.method)
        return nil if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method_name})
        /(#{aliases.sort_by(&:size).reverse.join("|")})$/.match(method_name)
      end


      def scope_name?(method, klass)
        associated_klass, associated_method = association_in_method(klass,  method)
                binding.pry

        associated_klass.named_scopes.include?(associated_method)
      end

      def replace_method(value)
        method.to_s.gsub(/(#{aliases.join("|")})$/, value)
      end
    end
  end
end
