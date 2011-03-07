module Searchlogic
  module CoreExt
    module Proc # :nodoc:
      def self.included(klass)
        klass.class_eval do
          attr_accessor :searchlogic_options

          def searchlogic_options
            @searchlogic_options ||= {}
            @searchlogic_options[:type] ||= :string
            @searchlogic_options
          end
        end
      end
    end
  end
end