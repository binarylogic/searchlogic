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
      
      def per_page # :nodoc:
        @per_page
      end
      
      # The default for per page. This is only applicaple for protected searches. Meaning you start the search with new_search or new_conditions.
      # The reason for this not to disturb regular queries such as Whatever.find(:all). You would not expect that to be limited.
      #
      # * <tt>Default:</tt> nil, nil means "show all"
      # * <tt>Accepts:</tt> Any value in your per_page choices
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
      
      def hidden_fields # :nodoc:
        @hidden_fields ||= (Search::Base::SPECIAL_FIND_OPTIONS - [:page])
      end
      
      # Which hidden fields to automatically include when creating a form with a Searchgasm object. See Searchgasm::Helpers::Form for more info.
      #
      # * <tt>Default:</tt> [:order_by, :order_as, :per_page]
      # * <tt>Accepts:</tt> Array, nil, false
      def hidden_fields=(value)
        @hidden_fields = value
      end
    end
  end
end