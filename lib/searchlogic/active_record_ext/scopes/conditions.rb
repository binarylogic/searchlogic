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
          scopeable?(name)  || super
        end

        def sl_conditions
          %w{_any _greater_than_or_equal_to _less_than_or_equal_to _equals _begins_with _does_not_equal _does_not_begin_with _ends_with _does_not_end_with _not_like _like _greater_than _less_than descend_by ascend_by _not_null _null _not_blank _blank or_}.join("|")
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