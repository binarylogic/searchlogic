module Searchgasm
  # = Config
  # Adds default configuration for all of searchgasm. Just make sure you set your config before you use Searchgasm.
  # For rails the best place to do this is in config/initializers. Create a file in there called searchgasm.rb with the following content:
  #
  # === Example
  #
  #   # config/iniitializers/searchgasm.rb
  #   Searchgasm::Config.configure do |config|
  #     config.you_option_here = your_value # see methods below
  #   end
  class Config
    class << self
      # Convenience method for setting configuration
      # See example at top of class.
      def configure
        yield self
      end
      
      def asc_indicator # :nodoc:
        @asc_indicator ||= "&nbsp;&#9650;"
      end
      
      # The indicator that is used when the sort of a column is ascending
      #
      # * <tt>Default:</tt> &nbsp;&#9650;
      # * <tt>Accepts:</tt> String or a Proc.
      #
      # === Examples
      #
      #   config.asc_indicator = "(ASC)"
      #   config.asc_indicator = Proc.new { |template| template.image_tag("asc.jpg") }
      def asc_indicator=(value)
        @asc_indicator = value
      end
      
      def desc_indicator # :nodoc:
        @desc_indicator ||= "&nbsp;&#9660;"
      end
      
      # See asc_indicator=
      def desc_indicator=(value)
        @desc_indicator = value
      end
      
      def hidden_fields # :nodoc:
        @hidden_fields ||= (Search::Base::SPECIAL_FIND_OPTIONS - [:page, :priority_order])
      end
      
      # Which hidden fields to automatically include when creating a form with a Searchgasm object. See Searchgasm::Helpers::Form for more info.
      #
      # * <tt>Default:</tt> [:order_by, :order_as, :per_page]
      # * <tt>Accepts:</tt> Array, nil, false
      def hidden_fields=(value)
        @hidden_fields = value
      end
      
      def page_links_first # :nodoc:
        @page_links_first
      end
      
      # The default for the :first option for the page_links helper.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> Anything you want, text, html, etc. nil to disable
      def page_links_first=(value)
        @page_links_first = value
      end
      
      def page_links_last # :nodoc:
        @page_links_last
      end
      
      # The default for the :last option for the page_links helper.
      #
      # * <tt>Default:</tt> nil
      # * <tt>Accepts:</tt> Anything you want, text, html, etc. nil to disable
      def page_links_last=(value)
        @page_links_last = value
      end
      
      def page_links_inner_spread # :nodoc:
        @page_links_inner_spread ||= 3
      end
      
      # The default for the :inner_spread option for the page_links helper.
      #
      # * <tt>Default:</tt> 3
      # * <tt>Accepts:</tt> Any integer >= 1, set to nil to show all pages
      def page_links_inner_spread=(value)
        @page_links_inner_spread = value
      end
      
      def page_links_outer_spread # :nodoc:
        @page_links_outer_spread ||= 1
      end
      
      # The default for the :outer_spread option for the page_links helper.
      #
      # * <tt>Default:</tt> 2
      # * <tt>Accepts:</tt> Any integer >= 1, set to nil to display, 0 to only show the "..." separator
      def page_links_outer_spread=(value)
        @page_links_outer_spread = value
      end
      
      def page_links_next # :nodoc:
        @page_links_next ||= "Next >"
      end
      
      # The default for the :next option for the page_links helper.
      #
      # * <tt>Default:</tt> "Next >"
      # * <tt>Accepts:</tt> Anything you want, text, html, etc. nil to disable
      def page_links_next=(value)
        @page_links_next = value
      end
      
      def page_links_prev # :nodoc:
        @page_links_prev ||= "< Prev"
      end
      
      # The default for the :prev option for the page_links helper.
      #
      # * <tt>Default:</tt> "< Prev"
      # * <tt>Accepts:</tt> Anything you want, text, html, etc. nil to disable
      def page_links_prev=(value)
        @page_links_prev = value
      end
      
      def per_page # :nodoc:
        @per_page ||= per_page_choices[1]
      end
      
      # The default for per page. This is only applicaple for protected searches. Meaning you start the search with new_search or new_conditions.
      # The reason for this not to disturb regular queries such as Whatever.find(:all). You would not expect that to be limited.
      #
      # * <tt>Default:</tt> The 3rd option in your per_page_choices, default of 50
      # * <tt>Accepts:</tt> Any value in your per_page choices, nil or a blank string means "show all"
      def per_page=(value)
        @per_page = value
      end
      
      def per_page_choices # :nodoc:
        @per_page_choices ||= [10, 25, 50, 100, 150, 200, nil]
      end
      
      # The choices used in the per_page helper
      #
      # * <tt>Default:</tt> [10, 25, 50, 100, 150, 200, nil]
      # * <tt>Accepts:</tt> Array
      #
      # nil means "Show all"
      def per_page_choices=(value)
        @per_page_choices = value
      end
      
      def remove_duplicates # :nodoc:
        return @remove_duplicates if @set_remove_duplicates
        @remove_duplicates ||= ::ActiveRecord::VERSION::MAJOR < 2 || (::ActiveRecord::VERSION::MAJOR == 2 && ::ActiveRecord::VERSION::MINOR < 2)
      end
      
      def remove_duplicates? # :nodoc:
        remove_duplicates == true
      end
      
      # If you are using ActiveRecord < 2.2.0 then ActiveRecord does not remove duplicates when using the :joins option, when it should. To fix this problem searchgasm does this for you. Searchgasm tries to act
      # just like ActiveRecord, but in this instance it doesn't make sense.
      #
      # As a result, Searchgasm removes all duplicates results in *ALL* search / calculation queries. It does this by forcing the DISTINCT or GROUP BY operation in your SQL. Which might come as a surprise to you
      # since it is not the "norm". If you don't want searchgasm to do this, set this to false.
      #
      # * <tt>Default:</tt> true
      # * <tt>Accepts:</tt> Boolean
      def remove_duplicates=(value)
        @set_remove_duplicates = true
        @remove_duplicates = value
      end
    end
  end
end