module Searchlogic
  module RailsHelpers
    def order(search, options = {}, html_options = {})
      options[:params_scope] ||= :search
      options[:as] ||= options[:by].to_s.humanize
      options[:ascend_scope] ||= "ascend_by_#{options[:by]}"
      options[:descend_scope] ||= "descend_by_#{options[:by]}"
      ascending = search.order.to_s == options[:ascend_scope]
      new_scope = ascending ? options[:descend_scope] : options[:ascend_scope]
      selected = [options[:ascend_scope], options[:descend_scope]].include?(search.order.to_s)
      if selected
        css_classes = html_options[:class] ? html_options[:class].split(" ") : []
        if ascending
          options[:as] = "&#9650;&nbsp;#{options[:as]}"
          css_classes << "ascending"
        else
          options[:as] = "&#9660;&nbsp;#{options[:as]}"
          css_classes << "descending"
        end
        html_options[:class] = css_classes.join(" ")
      end
      link_to options[:as], url_for(options[:params_scope] => {:order => new_scope}), html_options
    end

    def form_for(*args, &block)
      if search_obj = args.find { |arg| arg.is_a?(Searchlogic::Search) }
        options = args.extract_options!
        options[:html] ||= {}
        options[:html][:method] ||= :get
        args.unshift(:search) if args.first == search_obj
        args << options
      end
      super
    end

    def fields_for(*args, &block)
      if search_obj = args.find { |arg| arg.is_a?(Searchlogic::Search) }
        args.unshift(:search) if args.first == search_obj
        concat(hidden_field_tag("#{args.first}[order]", search_obj.order) + "\n")
        super
      else
        super
      end
    end
  end
end