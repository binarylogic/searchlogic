module Searchgasm
  module Condition
    class Keywords < Base
      BLACKLISTED_WORDS = ('a'..'z').to_a + ["about", "an", "are", "as", "at", "be", "by", "com", "de", "en", "for", "from", "how", "in", "is", "it", "la", "of", "on", "or", "that", "the", "the", "this", "to", "und", "was", "what", "when", "where", "who", "will", "with", "www"] # from ranks.nl        
      
      class << self
        def condition_names_for_column
          super + ["kwords", "kw"]
        end
      end
      
      def to_conditions(value)
        strs = []
        subs = []
        
        search_parts = value.gsub(/,/, " ").split(/ /).collect { |word| word.downcase.gsub(/[^[:alnum:]]/, ''); }.uniq.select { |word| !BLACKLISTED_WORDS.include?(word.downcase) && !word.blank? }
        return if search_parts.blank?
        
        search_parts.each do |search_part|
          strs << "#{column_sql} LIKE ?"
          subs << "%#{search_part}%"
        end
        
        [strs.join(" AND "), *subs]
      end
    end
  end
end