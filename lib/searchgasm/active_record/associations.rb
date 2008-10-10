module Searchgasm
  module ActiveRecord
    # = Searchgasm ActiveRecord Associations
    #
    # These methods hook into ActiveRecords association methods and add in searchgasm functionality.
    module Associations
      module AssociationCollection
        # This needs to be implemented because AR doesn't leverage scopes with this method like it probably should
        def find_with_searchgasm(*args)
          options = args.extract_options!
          args << filter_options_with_searchgasm(options)
          find_without_searchgasm(*args)
        end
      end
      
      module HasManyAssociation
        def count_with_searchgasm(*args)
          options = args.extract_options!
          args << filter_options_with_searchgasm(options)
          count_without_searchgasm(*args)
        end
      end
    end
  end
end

module ActiveRecord
  module Associations
    class AssociationCollection
      if respond_to?(:find)
        include Searchgasm::ActiveRecord::Associations::AssociationCollection
        alias_method_chain :find, :searchgasm
      end
    end
    
    class HasManyAssociation
      include Searchgasm::ActiveRecord::Associations::HasManyAssociation
      alias_method_chain :count, :searchgasm
      
      # Older versions of AR have find in here, not in AssociationCollection
      include Searchgasm::ActiveRecord::Associations::AssociationCollection
      alias_method_chain :find, :searchgasm
    end
  end
end