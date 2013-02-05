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
          puts condition_klass
          condition_klass.new(self, method)
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