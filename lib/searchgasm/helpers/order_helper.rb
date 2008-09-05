module Searchgasm
  module Helpers
    module OrderHelper
      # Creates a link for ordering data in a certain way.
      #
      # === Example uses for a User class that has many orders
      #   order_by(:first_name)
      #   order_by([:first_name, :last_name])
      #   order_by({:orders => :total})
      #   order_bt([{:orders => :total}, :first_name])
      #
      # The value gets "serialized" so that it can be passed via a param in the url. Searchgasm will automatically "unserializes" this value and uses it.
      #
      # === Options
      # Global options:
      # Please see Searchgasm::Helpers::Utilities.add_searchgasm_helper_defaults for all global options
      #
      # Local options:
      # * <tt>:text</tt> -- default: column_name.to_s.humanize, text for the link
      # * <tt>:desc_indicator</tt> -- default: &nbsp;&#9660;, the indicator that this column is descending
      # * <tt>:asc_indicator</tt> -- default: &nbsp;&#9650;, the indicator that this column is ascending
      # * <tt>:remote</tt> -- default: false, if true requests will be AJAX
      # * <tt>:html</tr> -- html_options for the link function
      def order_by(column_name, options = {})
        column_name = column_name.to_s
        add_searchgasm_helper_defaults!(options, :order_by)
        options[:text] ||= column_name.humanize
        options[:asc_indicator] ||= "&nbsp;&#9650;"
        options[:desc_indicator] ||= "&nbsp;&#9660;"
        options[:text] += options[:search].desc? ? options[:desc_indicator] : options[:asc_indicator] if options[:search].order_by == column_name
        link_to(options[:text], options[:url], options[:html])
      end
    end
  end
end

ActionController::Base.helper Searchgasm::Helpers::OrderHelper if defined?(ActionController)