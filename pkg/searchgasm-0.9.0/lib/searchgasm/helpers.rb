require "base64"

module BinaryLogic
  module SearchGasm
    module Helpers
      def order_by_link(text, searcher, options = {})
        options[:order_by] ||= text.underscore.gsub(/ /, "_")
        options[:order_as] ||= "ASC"
        options[:form_prefix] ||= determine_form_prefix(searcher)
    
        if searcher.order_by == options[:order_by]
          options[:order_as] = searcher.order_as == "ASC" ? "DESC" : "ASC"
      
          text = content_tag("span", text + (searcher.order_as == "ASC" ? "&nbsp;&#9650;" : "&nbsp;&#9660;"), :class => searcher.order_as == "ASC" ? "ordering asc" : "ordering desc")
        end
    
        options[:order_by] = Base64.encode64(Marshal.dump(options[:order_by])) if !options[:order_by].nil? && !options[:order_by].is_a?(String) && !options[:order_by].is_a?(Symbol)
    
        link_to_function(text, "submit_form({form_prefix: '#{options[:form_prefix]}', dont_reset: true, fields: {order_by: '#{escape_javascript(options[:order_by])}', order_as: '#{options[:order_as]}'}});")
      end
  
      # tag methods
      #------------------------------------------------------------------------------
      def page_select_tag(name, items_count, searcher, options = {})
        options = options.dup
        form_prefix = options.delete(:form_prefix) || determine_form_prefix(searcher)
        options[:id] ||= "select_tag_#{unique_id}"
        options[:onchange] ||= "submit_form({form_prefix: '#{form_prefix}', dont_reset: true, fields: {page: this.value}});"
        items_count = items_count.to_i
        per_page = searcher.per_page.to_i
        page = searcher.page.to_i
        page = 1 if page < 1
        page_options = page_options_for_select(items_count, per_page)
    
        html = ""
        if page_options.size > 0
          html << (button_to_function("Prev", "sel = $('#{options[:id]}'); sel.value = '#{page-1}'; sel.onchange();", :class => "prev_page") + "&nbsp;") if page > 1
          html << select_tag(name, options_for_select(page_options, page), options)
          html << ("&nbsp;" + button_to_function("Next", "sel = $('#{options[:id]}'); sel.value = '#{page+1}'; sel.onchange();", :class => "next_page")) if page < page_options.size
        end
        
        html
      end
  
      def per_page_select_tag(name, items_count, searcher, options = {})
        options = options.dup
        form_prefix = options.delete(:form_prefix) || determine_form_prefix(searcher)
        options[:onchange] ||= "submit_form({form_prefix: '#{form_prefix}', dont_reset: true, fields: {per_page: this.value}});"
        items_count = items_count.to_i
        per_page = searcher.per_page.to_i
        per_page = 0 if items_count <= per_page
    
        # set up per page options
        per_page_options = per_page_options_for_select(items_count)
    
        return select_tag(name, options_for_select(per_page_options, per_page), options) if per_page_options.size > 0
    
        ""
      end
  
      # utility methods
      #------------------------------------------------------------------------------
      def page_options_for_select(items_count, per_page)
        page_count = per_page > 0 ? (items_count.to_f / per_page.to_f).ceil : 1
        page_options = []
        if page_count > 1
          page_count.times do |page|
            page_number = page + 1
            page_options << ["Page #{page_number} of #{page_count}", page_number]
          end
        end
        page_options
      end
  
      def per_page_options_for_select(items_count)
        per_page_options = []
        per_page_values = [10, 20, 30, 40, 50, 75, 100, 125, 150, 175, 200, 300, 400, 500, 1000, 1500, 2000]
        per_page_values.each do |per_page_num|
          if items_count > per_page_num
            per_page_options << ["#{per_page_num} per page", per_page_num] if per_page_num > 0
          else
            break
          end
        end
    
        if per_page_options.size > 0
          per_page_options << ["Show all #{items_count}", 0]
        end
    
        per_page_options
      end
      
      def determine_form_prefix(searcher)
        "#{searcher.class.name.underscore.gsub(/_searcher/, "").pluralize}_search_"
      end
    end
  end
end

ActionController::Base.helper BinaryLogic::SearchGasm::Helpers