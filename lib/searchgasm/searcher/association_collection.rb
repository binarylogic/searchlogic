module BinaryLogic
  module Searchgasm
    module Searcher
      module AssociationCollection
        def build_search(attributes = {})
          searcher_class.new(attributes.merge(:scope => searcher_scope))
        end
        
        def search(attributes = {})
          searcher_class.search(attributes.merge(:scope => searcher_scope))
        end
          
        private
          def searcher_class
            "#{@reflection.klass.name}Searcher".constantize
          end
          
          def searcher_scope
            @owner.send(@reflection.name)
          end
      end
    end
  end
end

ActiveRecord::Associations::AssociationCollection.send(:include, BinaryLogic::Searchgasm::Searcher::AssociationCollection)