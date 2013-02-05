Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
module Searchlogic
  module Conditions
    private
      def method_missing(method, *args, &block) 
        generate_scope(method, args, &block) || super
      end

      def generate_scope(method, args, &block)
        klass = condition_klasses.find { |condition_klass| condition_klass.generate_scope(self, method, args, &block) }
        klass.generate_scope(self, method, args, &block) if klass
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
          LessThanOrEqualTo
        ]
      end
  end
end