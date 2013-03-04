require File.dirname(__FILE__) + '/aliases.rb'
module Searchlogic
  module ScopeReflectionExt
    module MatchAlias
      def convert_alias(method)
        # binding.pry
        self.method = method
        return method if match_alias.nil?
        alias_name = match_alias[1]
        replacement_value = "_" + alias_hash.find{|k, v| v.include?(alias_name)}.first.to_s
        replace_method(replacement_value)
      end

      def match_alias(method_name = method)
        return nil if !!(searchlogic_methods.detect{ |slm| /#{slm.to_s}$/ =~ method_name})
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
