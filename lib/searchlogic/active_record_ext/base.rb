module ActiveRecord
  class Base
    class << self
      protected
        # PostgreSQL raises an SQL error if you add DISTINCT to the select statement and then
        # order by a column that is not included in that select statement, but might be included in
        # a join. Without the DISTINCT call, no errors are raised. DISTINCT is heavily used throughout
        # this software, it is necessary to do this instead of using the ruby uniq! method because
        # its faster and it doesn't screw up pagination. That being said, this fix automatically adds
        # the column to the select statement, allowing the SQL to be valid. We have to do this automatically
        # because of scopes. We don't really know what we are ordering by, the scope could include anything.
        # Especially with searchlogic. There is a test for this, check it out for an example.
        def construct_finder_sql_with_auto_add_select(options)
          find_scope = scope(:find)
          if !options[:select].nil? && find_scope.is_a?(Hash) && find_scope[:order] && !(options[:select] =~ /^DISTINCT /i).nil?
            order_columns = find_scope[:order].split(/ ASC|DESC/i).collect { |c| c.gsub(/^,/ , "").strip }
            order_columns.each do |order_column|
              next if options[:select].include?(order_column)
              table = order_column.split(".").first
              next if options[:select].include?("#{table}.*")
              options[:select] += ", #{order_column}"
            end
          end
          construct_finder_sql_without_auto_add_select(options)
        end
    end
  end
end