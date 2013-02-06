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

      def generate_scope(method_klass, args, &block)
        method_name = find_method_and_klass(method_klass)[1]
        klass_name = find_method_and_klass(method_klass)[2]
        klass = condition_klasses.find  { |condition_klass| make_comparable(condition_klass) == klass_name }
        klass.generate_scope(self, method_name, args, &block) if klass
      end

      def scopeable?(method_klass)
        !(find_method_and_klass(method_klass).nil?) 
      end

      def find_method_and_klass(method_klass)
        if defined_method?(method_klass)
          re = /^(#{column_names.join("|")})_(#{joined_condition_klasses})/
          re.match(method_klass)
        end
      end

      def defined_method?(method)
        method.match(/_(#{joined_condition_klasses}$)/)
      end

      def joined_condition_klasses
        condition_klasses.map{ |k| make_comparable(k)}.join("|")
      end

      def make_comparable(const)
        const.to_s.split("::").last.underscore
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
          Blank
        ]
      end
  end
end