require File.dirname(__FILE__) + '/aliases.rb'
module Searchlogic
  module ScopeReflectionExt
    module MatchAlias
      def convert_alias(value = nil)
        self.method = method.to_s == "order" ? value : method
        return method if match_alias.nil? || scope_name?(method)
        alias_name = match_alias[1]
        replacement_value = self.class.alias_hash.find{|method, alias_array| alias_array.include?(alias_name)}.first.to_s
        replace_method(replacement_value)
      end

      def match_alias(method_name = self.method)
        return nil if !!(self.class.searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method_name})
        /(#{self.class.aliases.sort_by(&:size).reverse.join("|")})$/.match(method_name)
      end


      def scope_name?(method)
        associated_klass, associated_method = association_in_method(klass,  method)
        return nil if associated_klass.nil?
        new_method = associated_method.gsub(/^_/, "")
        associated_klass.singularize.capitalize.constantize.named_scopes.include?(new_method.to_sym)
      end

      def replace_method(value)
        method.to_s.gsub(/(#{self.class.aliases.join("|")})$/, value)
      end
    end
  end
end
