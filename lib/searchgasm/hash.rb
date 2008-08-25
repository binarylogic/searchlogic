module BinaryLogic
  module SearchGasm
    module Hash
      def merge_find_options!(new_options)
        if new_options.has_key?(:conditions)
          new_options[:conditions] = new_options[:conditions].to_a
          self[:conditions] = self[:conditions].to_a
          self[:conditions][0] = (self[:conditions].first.blank? ? "" : "(#{self[:conditions].first}) and ") + "(#{new_options[:conditions].shift})"
          self[:conditions] += new_options.delete(:conditions)
        end

        if new_options.has_key?(:include)
          new_options[:include] = new_options[:include].is_a?(Hash) ? [new_options[:include]] : new_options[:include].to_a
          self[:include] = self[:include].is_a?(Hash) ? [self[:include]] : self[:include].to_a
          new_include = new_options.delete(:include)
          self[:include] += new_include unless self[:include].include?(new_include)
        end

        new_options[:order] << ", #{self[:order]}" if new_options.has_key?(:order) && !self[:order].blank?

        merge!(new_options)
      end
    end
  end
end

Hash.send(:include, BinaryLogic::SearchGasm::Hash)