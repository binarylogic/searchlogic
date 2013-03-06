require File.dirname(__FILE__) + '/aliases.rb'
module Searchlogic
  module ScopeReflectionExt
    module MatchAlias

      def convert_alias(klass, options = {})
        self.method = options[:method].to_s == "order" ? options[:value] : options[:method]
        return method if match_alias.nil? || scope_from_association?(klass, method)
        alias_name = match_alias[1]
        replacement_value = alias_hash.find{|method, alias_array| alias_array.include?(alias_name)}.first.to_s
        replace_method(replacement_value)
      end

      def match_alias(method_name = self.method)
        return nil if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method_name})
        /(#{aliases.sort_by(&:size).reverse.join("|")})$/.match(method_name)
      end

      def scope_from_association?(klass, method)
        associated_klass, associated_method = klass.association_in_method(method)
        return nil if associated_klass.nil?
        new_method = associated_method.gsub(/^_/, "")
        associated_klass.singularize.capitalize.constantize.named_scopes.include?(new_method.to_sym)
      end

      def replace_method(value)
        method.to_s.gsub(/(#{aliases.join("|")})$/, value)
      end
    end
  end
end
