Dir[File.dirname(__FILE__) + '/conditions/*.rb'].each { |f| require(f) }
module Searchlogic
  module Conditions
    private
      def method_missing(method, *args, &block)
        find_condition(method.to_s).try(:process, args, &block) || super
      end

      def find_condition(method)
        condition_klasses.each do |condition_klass|
          condition = condition_klass.new(self, method)
          return condition if condition.applicable?(method)
        end
        nil
      end

      def condition_klasses
        [
          Equals
        ]
      end
  end
end