require Dir[File.dirname(__FILE__) + '/conditions/chronic_support.rb'].first
require Dir[File.dirname(__FILE__) + '/conditions/condition.rb'].first
Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }

module Searchlogic
  module ActiveRecordExt
    module Scopes
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
          return memoized_scope[method] if memoized_scope[method]
          generate_scope(method, args, &block) || super
        end
        def generate_scope(method, args, &block)
          condition_klasses.each do |ck|
            scope = ck.generate_scope(self, method, args, &block)
            if scope 
              memoized_scope[method] = scope 
              return scope
            end
          end
          nil
        end

        def memoized_scope
          {}
        end

        def scopeable?(method)
          !!(/(#{joined_condition_klasses})/.match(method)) || !!(Aliases.match_alias(method))
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
            ScopeProcedure,
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
            NotBlank,
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
  end
end