module Searchgasm
  module Helpers
    # = Control Type Helpers
    #
    # The purpose of these helpers is to make ordering and paginating data, in your view, a breeze. Everyone has their own flavor of displaying data, so I made these helpers extra flexible, just for you.
    #
    # === Tutorial
    #
    # Check out my tutorial on how to implement searchgasm into a rails app: http://www.binarylogic.com/2008/9/7/tutorial-pagination-ordering-and-searching-with-searchgasm
    #
    # === How it's organized
    #
    # If we break it down, you can do 4 different things with your data in your view:
    #
    # 1. Order your data by a single column or an array of columns
    # 2. Descend or ascend your data
    # 3. Change how many items are on each page
    # 4. Paginate through your data
    #
    # Each one of these actions comes with 3 different types of helpers:
    #
    # 1. Link - A single link for a single value. Requires that you pass a value as the first parameter.
    # 2. Links - A group of single links.
    # 3. Select - A select with choices that perform an action once selected. Basically the same thing as a group of links, but just as a select form element
    # 4. Remote - lets you prefix any of these helpers with "remote_" and it will use the built in rails ajax helpers. I highly recommend unobstrusive javascript though, using jQuery.
    #
    # === Examples
    #
    # Sometimes the best way to explain something is with some examples. Let's pretend we are performing these actions on a User model. Check it out:
    #
    #   order_by_link(:name)
    #   => produces a single link that when clicked will order by the name column, and each time its clicked alternated between "ASC" and "DESC"
    #
    #   order_by_links
    #   => produces a group of links for all of the columns in your users table, each link is basically order_by_link(column.name)
    #
    #   order_by_select
    #   => produces a select form element with all of the user's columns as choices, when the value is change (onchange) it will act as if they clicked a link.
    #   => This is just order_by_links as a select form element, nothing fancy
    #
    # What about paginating? I got you covered:
    #
    #   page_link(2)
    #   => creates a link to page 2
    #
    #   page_links
    #   => creates a group of links for pages, similar to a flickr style of pagination
    #
    #   page_select
    #   => creates a drop down instead of a group of links. The user can select the page in the drop down and it will be as if they clicked a link for that page.
    #
    # You can apply the _link, _links, or _select to any of the following: order_by, order_as, per_page, page. You have your choice on how you want to set up the interface. For more information and options on these individual
    # helpers check out their source files. Look at the sub modules under this one (Ex: Searchgasm::Helpers::ControlTypes::Select)
    module ControlTypes
    end
  end
end