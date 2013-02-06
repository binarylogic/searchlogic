Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
require 'pry'
module Searchlogic
  module Conditions
      def respond_to?(*args)
        name = args.first
        scopeable?(name) || super
      end
    private
      def method_missing(method, *args, &block) 
        generate_scope(method, args, &block) || super
      end

      def generate_scope(method, args, &block)
        klass = condition_klasses.find  { |ck| condition_klass_matches_method?(ck, method) }
        return nil unless klass 
        klass.generate_scope(self, method, args, &block)
      end

      def scopeable?(method)
        !(match_klass(method).nil?) 
      end

      def match_klass(method)
        /(#{joined_condition_klasses})/.match(method)
      end

      def joined_condition_klasses
        condition_klasses.map{ |k| make_comparable(k)}.join("|")
      end

      def make_comparable(const)
        const.to_s.split("::").last.underscore
      end

      def condition_klass_matches_method?(condition_klass, method)        
        match = match_klass(method)
        possible_matches = (1..match.length).map do |match_num|
          match[match_num]
        end
        possible_matches.include?(make_comparable(condition_klass))
      end

      def condition_klasses
        [
          Equals,
          Like,
          BeginsWith,
          DoesNotEqual,
          DoesNotBeginWith,
          EndsWith,
          DoesNotEndWith,
          GreaterThanOrEqualTo,
          LessThanOrEqualTo,
          NotLike,
          GreaterThan,
          LessThan,
          Null,
          NotNull,
          Blank,
          AscendBy,
          DescendBy
        ]
      end
  end
end