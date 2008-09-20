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
      
        # See build_conditions under Searchgasm::ActiveRecord::Base. This is the same thing but for associations.
        def build_conditions(options = {}, &block)
          @reflection.klass.send(:with_scope, :find => construct_scope[:find]) { @reflection.klass.build_conditions(options, &block) }
        end
      
        # See build_conditions! under Searchgasm::ActiveRecord::Base. This is the same thing but for associations.
        def build_conditions!(options = {}, &block)
          @reflection.klass.send(:with_scope, :find => construct_scope[:find]) { @reflection.klass.build_conditions!(options, &block) }
        end
      
        # See build_search under Searchgasm::ActiveRecord::Base. This is the same thing but for associations.
        def build_search(options = {}, &block)
          @reflection.klass.send(:with_scope, :find => construct_scope[:find]) { @reflection.klass.build_search(options, &block) }
        end
      
        # See build_conditions! under Searchgasm::ActiveRecord::Base. This is the same thing but for associations.
        def build_search!(options = {}, &block)
          @reflection.klass.send(:with_scope, :find => construct_scope[:find]) { @reflection.klass.build_search!(options, &block) }
        end
      end
      
      module Shared
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
      include Searchgasm::ActiveRecord::Associations::AssociationCollection
      
      alias_method_chain :find, :searchgasm
    end
    
    class HasManyAssociation
      include Searchgasm::ActiveRecord::Associations::Shared
      
      alias_method_chain :count, :searchgasm
    end
  end
end