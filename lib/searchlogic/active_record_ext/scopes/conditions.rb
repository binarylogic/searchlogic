require Dir[File.dirname(__FILE__) + '/conditions/chronic_support.rb'].first
require Dir[File.dirname(__FILE__) + '/conditions/condition.rb'].first
require_relative "../../aliases_converter.rb"
Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }

module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        def respond_to?(*args)
          name = args.first
          scopeable?(name) || super
        end

        def sl_conditions
          %w{_any greater_than_or_equal_to less_than_or_equal_to equals begins_with does_not_equal does_not_begin_with ends_with does_not_end_with not_like like greater_than less_than not_null null not_blank blank or_}.join("|_") + "|ascend_by|descend_by"
        end

        def tables
          ActiveRecord::Base.connection.tables
        end
        
        private
        def method_missing(method, *args, &block) 
          std_method = AliasesConverter.new(self, method, args).scope
          return memoized_scope[std_method] if memoized_scope[std_method]
          generate_scope(std_method, args, &block) || super
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
          !!(/(#{sl_conditions})/.match(method)) || !!(AliasesConverter.match_alias(method))
        end

        def condition_klasses
         [  
            NormalizeInput,
            Polymorphic,
            Any,
            Oor,
            GreaterThanOrEqualTo,
            LessThanOrEqualTo,
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
            All
          ] 
        end
      end
    end
  end
end