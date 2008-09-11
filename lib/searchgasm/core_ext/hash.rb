module Searchgasm
  module CoreExt # :nodoc: all
    module Hash
      def deep_dup
        new_hash = {}
        
        self.each do |k, v|
          case v
          when Hash
            new_hash[k] = v.deep_dup
          else
            new_hash[k] = v
          end
        end
        
        new_hash
      end
    end
  end
end

Hash.send(:include, Searchgasm::CoreExt::Hash)