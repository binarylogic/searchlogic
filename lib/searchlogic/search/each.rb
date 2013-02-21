module Searchlogic
  class Search < Base
    module Each
      include Enumerable
      def each(&block)
        self.all.each do |member|
          block.call(member)
        end
      end 
    end
  end
end