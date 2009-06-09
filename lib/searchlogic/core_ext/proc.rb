module Searchlogic
  module CoreExt
    module Proc
      def self.included(klass)
        klass.class_eval do
          attr_accessor :searchlogic_arg_type
        end
      end
    end
  end
end