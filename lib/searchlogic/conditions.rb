Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
require 'pry'
module Searchlogic
  module Conditions
      def respond_to?(*args)
        name = args.first
        applicable?(name) || super
      end
    private
      def method_missing(method, *args, &block) 
        generate_scope(method, args, &block) || super
      end

      def generate_scope(method, args, &block)
        klass = condition_klasses.find  { |condition_klass| condition_klass.generate_scope(self, method, args, &block) }
        klass.generate_scope(self, method, args, &block) if klass
      end

      def applicable?(method)
        !(match_method(method).nil?) unless method.match(/connection/)
      end

      def match_method(method)
        re = %r{^(#{column_names.join("|")})_(#{condition_klasses.map{ |k| k.to_s.split("::").last.underscore}.join("|")})}
        re.match(method)
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
          NotLike,
          GreaterThan,
          LessThan,
          GreaterThanOrEqualTo,
          LessThanOrEqualTo,
          Null,
          NotNull,
          Blank
        ]
      end
  end
end