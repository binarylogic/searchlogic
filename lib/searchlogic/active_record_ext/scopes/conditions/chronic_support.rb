module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        module ChronicSupport
          def parsed_string_input
            if defined?(Chronic)
              Chronic.parse(args.first)
            else
              raise "Strings are not a valid argument. If you're trying to use Chronic add it to your Gemfile"
            end
          end

          def value
            args.first.kind_of?(String) ? parsed_string_input : args.first
          end
        end
      end
    end
  end
end
