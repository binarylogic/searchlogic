require 'cgi'
module Searchlogic
  module SearchExt
    module Methods

      def to_params(namespace = nil)
        conditions do |key, value|
          value.to_query(namespace ? "#{namespace}[#{key}]" : key)
        end.sort * '&'
      end

      def delete(args)
        args = args.first if args.kind_of?(Array)
        conditions.delete(args.to_sym) 
      end
    end
  end
end
