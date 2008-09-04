module BinaryLogic
  module Searchgasm
    module Helpers
      module PaginationHelper
        def page(options = {})
          options[:javascript] = true
          add_searchgasm_helper_defaults!(options, :page)
          return "" if options[:search].page_count <= 1
          options[:html] ||= {}
          options[:html][:onchange] ||= options[:url]
          select(:search, :page, (1..options[:search].page_count), {}, options[:html])
        end
        
        def per_page(options = {})
          options[:javascript] = true
          add_searchgasm_helper_defaults!(options, :per_page)
          
          options[:choices] = [10, 25, 50, 100, 150, 200, nil]
          if !options[:search].per_page.blank? && !options[:choices].include?(options[:search].per_page)
            options[:choices] << options[:search].per_page
            options[:choices].sort!
          end
          options[:choices] = options[:choices].collect { |choice| [choice == nil ? "Show all" : "#{choice} per page", choice] }
                    
          #link_to "page 2", url_for(:search => {:page => 2, :per_page => 5, :conditions => options[:search].conditions(true)})
          options[:html] ||= {}
          options[:html][:onchange] ||= options[:url]
          
          select(:search, :per_page, options[:choices], {}, options[:html])
        end
      end
    end
  end
end

ActionController::Base.helper BinaryLogic::Searchgasm::Helpers::PaginationHelper if defined?(ActionController)