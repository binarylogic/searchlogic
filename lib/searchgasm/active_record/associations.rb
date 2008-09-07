module Searchgasm
  module ActiveRecord
    module Associations
      module AssociationCollection
        def find_with_searchgasm(*args)
          options = args.extract_options!
          args << sanitize_options_with_searchgasm(options)
          find_without_searchgasm(*args)
        end
        
        def build_conditions(options = {}, &block)
          conditions = @reflection.klass.build_conditions(options, &block)
          conditions.scope = scope(:find)[:conditions]
          conditions
        end
        
        def build_conditions!(options = {}, &block)
          conditions = @reflection.klass.build_conditions!(options, &block)
          conditions.scope = scope(:find)[:conditions]
          conditions
        end
      
        def build_search(options = {}, &block)
          conditions = @reflection.klass.build_search(options, &block)
          conditions.scope = scope(:find)[:conditions]
          conditions
        end
        
        def build_search!(options = {}, &block)
          conditions = @reflection.klass.build_search!(options, &block)
          conditions.scope = scope(:find)[:conditions]
          conditions
        end
      end
    
      module HasManyAssociation
        def count_with_searchgasm(*args)
          column_name, options = @reflection.klass.send(:construct_count_options_from_args, *args)
          count_without_searchgasm(column_name, sanitize_options_with_searchgasm(options))
        end
      end
    end
  end
end

ActiveRecord::Associations::AssociationCollection.send(:include, Searchgasm::ActiveRecord::Associations::AssociationCollection)

module ActiveRecord
  module Associations
    class AssociationCollection
      alias_method_chain :find, :searchgasm
    end
  end
end

ActiveRecord::Associations::HasManyAssociation.send(:include, Searchgasm::ActiveRecord::Associations::HasManyAssociation)

module ActiveRecord
  module Associations
    class HasManyAssociation
      alias_method_chain :count, :searchgasm
    end
  end
end