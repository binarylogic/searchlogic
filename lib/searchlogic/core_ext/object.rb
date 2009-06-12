module Searchlogic
  module CoreExt
    # Contains extensions for the Object class that Searchlogic uses.
    module Object
      # Searchlogic needs to know the expected type of the condition value so that it can properly cast
      # the value in the Searchlogic::Search object. For example:
      #
      #   search = User.search(:id_gt => "1")
      #
      # You would expect this:
      #
      #   search.id_gt => 1
      #
      # Not this:
      #
      #   search.id_gt => "1"
      #
      # Parameter values from forms are ALWAYS strings, so we have to cast them. Just like ActiveRecord
      # does when you instantiate a new User object.
      #
      # The problem is that ruby has no variable types, so Searchlogic needs to know what type you are expecting
      # for your named scope. So instead of this:
      #
      #   named_scope :id_gt, lambda { |value| {:conditions => ["id > ?", value]} }
      #
      # You need to do this:
      #
      #   named_scope :id_gt, searchlogic_lambda(:integer) { |value| {:conditions => ["id > ?", value]} }
      #
      # If you are wanting a string, you don't have to do anything, because Searchlogic assumes you are want a string.
      # If you want something else, you need to specify it as I did in the above example.
      def searchlogic_lambda(type = :string, &block)
        proc = lambda(&block)
        proc.searchlogic_arg_type = type
        proc
      end
    end
  end
end