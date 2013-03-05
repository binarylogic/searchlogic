module Searchlogic
  module SearchExt
    module Delete
      def delete(args)
        args = args.first if args.kind_of?(Array)
        conditions.delete(args.to_sym) 
      end
    end
  end
end
