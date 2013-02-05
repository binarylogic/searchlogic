Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
module Searchlogic
  module Conditions
    private
      def method_missing(method, *args, &block)
        find_condition(method.to_s).try(:generate_scope, args, &block) || super
      end

      def find_condition(method)
        puts "finding conditiond "
        condition_klasses.each do |condition_klass|
          return condition_klass.new(self, method)
        end
      end

      def valid_condition?(condition)
        condition.downcase!
        condition.capitalize!
        puts condition.constantize
        condition_klasses.select{ |klass| condition == klass }
      end

      def condition_klasses
        [
          Equals
        ]
      end
  end
end