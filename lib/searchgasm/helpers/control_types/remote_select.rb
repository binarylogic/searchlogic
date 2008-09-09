module Searchgasm
  module Helpers
    module ControlTypes
      module RemoteSelect
        # Please see order_by_links. All options are the same and applicable here. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def remote_order_by_select(options = {})
          add_remote_defaults!(options)
          order_by_select(options)
        end
        
        # Please see order_as_links. All options are the same and applicable here. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def remote_order_as_select(options = {})
          add_remote_defaults!(options)
          order_as_select(options)
        end
        
        # Please see per_page_links. All options are the same and applicable here. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def remote_per_page_select(options = {})
          add_remote_defaults!(options)
          per_page_select(options)
        end
        
        # Please see page_links. All options are the same and applicable here, excep the :prev, :next, :first, and :last options. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def remote_page_select(options = {})
          add_remote_defaults!(options)
          page_select(options)
        end
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::ControlTypes::RemoteSelect if defined?(ActionController)