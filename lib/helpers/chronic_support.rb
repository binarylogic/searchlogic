module ChronicSupport
  def value
    args.first.kind_of?(String) ? parsed_string_input : args.first
  end
  
  def parsed_string_input
    if defined?(Chronic)
      Chronic.parse(args.first)
    else
      "Strings are not a valid argument unless you're searching for a time and have Chronic in your gemfile"
    end
  end
end