require File.dirname(__FILE__) + '/aliases.rb'
module Searchlogic
  module ScopeReflectionExt
    module MatchAlias
      def convert_alias(method)
        self.method = method

        return method if match_alias.nil?

        alias_name = match_alias[1]
        if equals_alias.include?(alias_name)
          replace_method("_equals")
        elsif does_not_equal_alias.include?(alias_name)
          replace_method("_does_not_equal")
        elsif less_than_alias.include?(alias_name)
          replace_method("_less_than")
        elsif less_than_or_equal_to_alias.include?(alias_name)
          replace_method("_less_than_or_equal_to")
        elsif greater_than_alias.include?(alias_name)
          replace_method("_greater_than")
        elsif greater_than_or_equal_to_alias.include?(alias_name)
          replace_method("_greater_than_or_equal_to")
        elsif like_alias.include?(alias_name)
          replace_method("_like")
        elsif not_like_alias.include?(alias_name)
          replace_method("_not_like")
        elsif begins_with_alias.include?(alias_name)
          replace_method("_begins_with")
        elsif does_not_begin_with_alias.include?(alias_name)
          replace_method("_does_not_begin_with")
        elsif ends_with_alias.include?(alias_name)
          replace_method("_ends_with")
        elsif does_not_end_with_alias.include?(alias_name)
          replace_method("_does_not_end_with")
        elsif null_alias.include?(alias_name)
          replace_method("_null")
        elsif not_null_alias.include?(alias_name)
          replace_method("_not_null")
        elsif not_blank_alias.include?(alias_name)
          replace_method("_not_blank")
        else
          nil
        end
      end

      def match_alias(method_name = method)
        return nil if !!(searchlogic_methods.detect{ |slm| method.to_s.include?(slm)})
        /(#{aliases.sort_by(&:size).reverse.join("|")})$/.match(method_name)
      end

      def aliases
        f = File.open(File.dirname(__FILE__) + '/aliases.rb')
        f.readlines.select do |line| 
          /[\%w]/ =~ line 
        end.map { |line| re = /\%w\{(.*)\}/; re.match(line)[1].split(" ") if re.match(line)}.flatten.compact.sort_by(&:size).reverse.map(&:strip)
      end

      def replace_method(replacement_method)
        method.to_s.gsub(/(#{aliases.join("|")})$/, replacement_method)
      end
    end
  end
end
