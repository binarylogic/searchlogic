module Searchgasm
  module Search
    # = Search Ordering
    #
    # The purpose of this module is to provide easy ordering for your searches. All that these options do is
    # build :order for you. This plays a huge part in ordering your data on the interface. See the options and examples below. The readme also touches on ordering. It's pretty simple thought:
    #
    # === Examples
    #
    #   search.order_by = :id
    #   search.order_by = [:id, :first_name]
    #   search.order_by = {:user_group => :name}
    #   search.order_by = [:id, {:user_group => :name}]
    #   search.order_by = {:user_group => {:account => :name}} # you can traverse through all of your relationships
    #
    #   search.order_as = "DESC"
    #   search.order_as = "ASC"
    module Ordering
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :include, :ordering
          alias_method_chain :order=, :ordering
        end
      end
      
      def include_with_ordering # :nodoc:
        includes = [include_without_ordering, order_by_includes].flatten.compact.uniq
        includes.blank? ? nil : (includes.size == 1 ? includes.first : includes)
      end
      
      def order_with_ordering=(value) # :nodoc
        @order_by = nil
        self.order_without_ordering = value
      end
      
      # Convenience method for determining if the ordering is ascending
      def asc?
        !desc?
      end
      
      # Convenience method for determining if the ordering is descending
      def desc?
        order_as == "DESC"
      end
      
      # Determines how the search is being ordered: as DESC or ASC
      def order_as
        return "ASC" if order.blank?
        order =~ /ASC$/i ? "ASC" : "DESC"
      end
      
      # Sets how the results will be ordered: ASC or DESC
      def order_as=(value)
        value = value.to_s.upcase
        raise(ArgumentError, "order_as only accepts a string as ASC or DESC") unless ["ASC", "DESC"].include?(value)
        
        if order.blank?
          self.order = order_by_to_order(order_by, value)
        else
          self.order.gsub!(/(ASC|DESC)/i, value)
        end
        
        value
      end
      
      # Determines by what columns the search is being ordered. This is nifty in that is reverse engineers the order SQL to determine this, only
      # if you haven't explicitly set the order_by option yourself.
      def order_by
        return @order_by if @order_by
        
        if !order.blank?
          # Reversege engineer order, only go 1 level deep with relationships, anything beyond that is probably excessive and not good for performance
          order_parts = order.split(",").collect do |part|
            part.strip!
            part.gsub!(/ (ASC|DESC)$/i, "").gsub!(/(.*)\./, "")
            table_name = ($1 ? $1.gsub(/[^a-z0-9_]/i, "") : nil)
            part.gsub!(/[^a-z0-9_]/i, "")
            reflection = nil
            if table_name && table_name != klass.table_name
              reflection = klass.reflect_on_association(table_name.to_sym) || klass.reflect_on_association(table_name.singularize.to_sym)
              next unless reflection
              {reflection.name.to_s => part}
            else
              part
            end
          end.compact
          order_parts.size <= 1 ? order_parts.first : order_parts
        else
          klass.primary_key
        end
      end
      
      # Lets you set how to order the data
      #
      # === Examples
      #
      # In these examples "ASC" is determined by the value of order_as
      #
      #   order_by = :id # => users.id ASC
      #   order_by = [:id, name] # => users.id ASC, user.name ASC
      #   order_by = [:id, {:user_group => :name}] # => users.id ASC, user_groups.name ASC
      def order_by=(value)        
        @order_by = get_order_by_value(value)
        @order = order_by_to_order(@order_by, order_as) # use @order so @order_by doesnt get reset
        @order_by
      end
      
      # Returns the includes neccessary for the "order" statement so that we don't get an SQL error
      def order_by_includes
        @order_by_includes ||= []
        @order_by_includes.compact!
        @order_by_includes.uniq!
        @order_by_includes
      end
      
      private
        def order_by_to_order(order_by, order_as, alt_klass = nil, new_includes = [])
          table_name = (alt_klass || klass).table_name
          sql_parts = []
          
          case order_by
          when Array
            order_by.each { |part| sql_parts << order_by_to_order(part, order_as) }
          when Hash
            raise(ArgumentError, "when passing a hash to order_by you must only have 1 key: {:user_group => :name} not {:user_group => :name, :user_group => :id}. The latter should be [{:user_group => :name}, {:user_group => :id}]") if order_by.keys.size != 1
            k = order_by.keys.first
            v = order_by.values.first
            new_includes << k.to_sym
            sql_parts << order_by_to_order(v, order_as, eval(k.to_s.classify), new_includes) # using eval, better performance, protection makes sure nothing fishy goes on here
          when Symbol, String
            new_include = build_order_by_includes(new_includes)
            self.order_by_includes << new_include if new_include
            sql_parts << "#{quote_table_name(table_name)}.#{quote_column_name(order_by)} #{order_as}"
          end
          
          sql_parts.join(", ")
        end
        
        def build_order_by_includes(includes)
          return includes.first if includes.size <= 1
          includes = includes.dup
          
          key = includes.shift
          {key => build_order_by_includes(includes)}
        end
        
        def get_order_by_value(value)
          Marshal.load(value.unpack("m").first) rescue value
        end
        
        def quote_column_name(column_name)
          klass_connection.quote_column_name(column_name)
        end

        def quote_table_name(table_name)
          klass_connection.quote_table_name(table_name)
        end
        
        def klass_connection
          @connection ||= klass.connection
        end
    end
  end
end