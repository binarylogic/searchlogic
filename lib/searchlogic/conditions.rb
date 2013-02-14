require 'searchlogic/conditions/condition'
Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
require 'pry'
module Searchlogic
  module Conditions
      def respond_to?(*args)
        name = args.first
        scopeable?(name) || super
      end

      def joined_condition_klasses
        condition_klasses.map{ |k| make_comparable(k)}.join("|")
      end

      def tables
        ActiveRecord::Base.connection.tables
      end
      
    private
      def method_missing(method, *args, &block) 
        generate_scope(method, args, &block) || super
      end

      def generate_scope(method, args, &block)
        condition_klasses.each do |ck|
          scope = ck.generate_scope(self, method, args, &block)
          return scope if scope
        end
        nil
      end

      def scopeable?(method)
        /(#{joined_condition_klasses})/.match(method)
      end

      def condition_klasses
        #NOTE DO NOT FUCK WITH THIS ORDER


       [  
          NormalizeInput,
          Polymorphic,
          Any,
          GreaterThanOrEqualTo,
          LessThanOrEqualTo,
          Oor,
          Joins,
          Equals,
          BeginsWith,
          DoesNotEqual,
          DoesNotBeginWith,
          EndsWith,
          DoesNotEndWith,
          NotLike,
          Like,
          GreaterThan,
          LessThan,
          NotNull,
          Null,
          Blank,
          AscendBy,
          DescendBy,
          All,
          Aliases
        ] 
      end

      def make_comparable(const)
        const.to_s.split("::").last.underscore
      end

  end
end