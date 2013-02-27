module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope_procedure(name, scope)
          singleton_class.instance_eval do
            define_method(name) do |*args|
              case scope.arity
              when -1
                scope.call(*args)
              when 0
                scope.call
              when 1
                scope.call(args)
              when 2
                scope.call(args[0], args[1])
              when 3
                scope.call(args[0], args[1], args[2])
              when 4
                scope.call(args[0], args[1], args[2], args[3], args[4])
              when 5
                scope.call(args[0], args[1], args[2], args[3], args[4], args[5])
              when 6
                scope.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6])
              when 7
                scope.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
              when 8
                scope.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
              when 9
                scope.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
              when 10
                scope.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10])
              end
            end
          end
          searchlogic_scopes.push(name)
        end
      end
    end
  end
end