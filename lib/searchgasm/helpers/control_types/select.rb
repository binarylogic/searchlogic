module Searchgasm
  module Helpers
    module ControlTypes
      # = Select Control Types
      #
      # These create <select> tags to help navigate through search data. This is here as an alternative to the Links control types.
      module Select
        # Please see order_by_links. All options are the same and applicable here. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def order_by_select(options = {})
          add_order_by_select_defaults!(options)
          searchgasm_state(options) + select(options[:params_scope], :order_by, options[:choices], options[:tag], options[:html] || {})
        end
        
        # Please see order_as_links. All options are the same and applicable here. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def order_as_select(options = {})
          add_order_as_select_defaults!(options)
          searchgasm_state(options) + select(options[:params_scope], :order_as, options[:choices], options[:tag], options[:html])
        end
        
        # Please see per_page_links. All options are the same and applicable here. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def per_page_select(options = {})
          add_per_page_select_defaults!(options)
          searchgasm_state(options) + select(options[:params_scope], :per_page, options[:choices], options[:tag], options[:html])
        end
        
        # Please see page_links. All options are the same and applicable here, excep the :prev, :next, :first, and :last options. The only difference is that instead of a group of links, this gets returned as a select form element that will perform the same function when the value is changed.
        def page_select(options = {})
          add_page_select_defaults!(options)
          searchgasm_state(options) + select(options[:params_scope], :page, (options[:first_page]..options[:last_page]), options[:tag], options[:html])
        end
        
        private
          def add_order_by_select_defaults!(options)
            add_order_by_links_defaults!(options)
            add_searchgasm_select_defaults!(:order_by, options)
            options
          end
          
          def add_order_as_select_defaults!(options)
            add_order_as_links_defaults!(options)
            add_searchgasm_select_defaults!(:order_as, options)
            options
          end
          
          def add_per_page_select_defaults!(options)
            add_per_page_links_defaults!(options)
            options[:choices] = options[:choices].collect { |choice| choice.nil? ? ["Show all", choice] : ["#{choice} per page", choice]}
            add_searchgasm_select_defaults!(:per_page, options)
            options
          end
          
          def add_page_select_defaults!(options)
            add_page_links_defaults!(options)
            add_searchgasm_select_defaults!(:page, options)
            options
          end
          
          def add_searchgasm_select_defaults!(option, options)
            options[:tag] ||= {}
            options[:tag][:object] = options[:search_obj]
            
            url = searchgasm_url(options.merge(:literal_search_params => {option => "'+this.value+'"}))
            
            options[:html][:onchange] ||= ""
            options[:html][:onchange] += ";"
            if !options[:remote]
              options[:html][:onchange] += "window.location='#{url}';"
            else
              options[:html][:onchange] += remote_function(:url => url, :method => :get).gsub(/\\'\+this.value\+\\'/, "'+this.value+'")
            end
            options[:html][:id] ||= ""
            options
          end
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::ControlTypes::Select if defined?(ActionController)