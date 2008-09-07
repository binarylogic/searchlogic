module Searchgasm
  module Search
    module Pagination
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :limit=, :pagination
          alias_method_chain :offset=, :pagination
          alias_method :per_page, :limit
          alias_method :per_page=, :limit=
        end
      end
      
      def limit_with_pagination=(value)
        self.limit_without_pagination = value
        self.page = @page unless @page.nil? # retry page now that the limit has changed
        limit
      end
      
      def offset_with_pagination=(value)
        self.offset_without_pagination = value
        @page = nil
        offset
      end
      
      def page
        return 1 if offset.blank? || limit.blank?
        (offset.to_f / limit).floor + 1
      end
      
      def page=(value)
        # Have to use @offset, since self.offset= resets @page
        if value.nil?
          @page = value
          return @offset = value
        end
        
        v = value.to_i
        @page = v
        
        if limit.blank?
          @offset = nil
        else
          v -= 1 unless v == 0
          @offset = v * limit
        end
        value
      end
      
      def page_count
        return 1 if per_page.blank? || per_page <= 0
        # Letting AR caching kick in with the count query
        (count / per_page.to_f).ceil
      end
      alias_method :page_total, :page_count
      
      def next_page!
        raise("You are on the last page") if page == page_count
        self.page += 1
        all
      end
      
      def prev_page!
        raise("You are on the first page") if page == 1
        self.page -= 1
        all
      end
    end
  end
end