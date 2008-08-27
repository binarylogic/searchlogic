module BinaryLogic
  module Searchgasm
    module Searcher
      class AssociationCollection
        def build_search(attributes = {})
          raise @reflection.inspect
          "#{@reflection.klass.name}Searcher".constantize
        end
      end
    end
  end
end

ActiveRecord::Associations::AssociationCollection.send(:include, BinaryLogic::Searchgasm::Searcher::AssociationCollection)