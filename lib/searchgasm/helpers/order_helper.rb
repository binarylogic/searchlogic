module BinaryLogic
  module Searchgasm
    module Helpers
      module OrderHelper
        def order_by(column_name, options = {})
          column_name = column_name.to_s
          options[:order_by] ||= column_name
          add_searchgasm_helper_defaults!(options, :order_by)
          options[:text] ||= column_name.humanize
          options[:asc_indicator] ||= "&nbsp;&#9650;"
          options[:desc_indicator] ||= "&nbsp;&#9660;"
          options[:text] += options[:search].desc? ? options[:desc_indicator] : options[:asc_indicator] if options[:search].order_by == column_name
          link_to(options[:text], options[:url])
        end
      end
    end
  end
end

ActionController::Base.helper BinaryLogic::Searchgasm::Helpers::OrderHelper if defined?(ActionController)