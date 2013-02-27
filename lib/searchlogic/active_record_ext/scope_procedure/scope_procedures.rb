module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope_procedure(name, scope)
          if scope.kind_of?(Hash)
            scope_with_conditions_hash(name, scope)    
          elsif scope.kind_of?(Proc)
            scope_with_proc(name, scope)  
          end
          searchlogic_scopes.push(name)
        end

        def scope_with_conditions_hash(method_name, hash)
          singleton_class.instance_eval do
            define_method(method_name) do
              first_conditions = hash[:conditions].shift
              initial_scope = self.send(first_conditions[0], first_conditions[1])
              hash[:conditions].inject(initial_scope){|scope, (s, v)| scope.send(s,v)}
            end
          end
        end

        def scope_with_proc(method_name, proc)
          singleton_class.instance_eval do
            define_method(method_name) do |*args|
              case proc.arity
              when -1
                proc.call(*args)
              when 0
                proc.call
              when 1
                proc.call(args)
              when 2
                proc.call(args[0], args[1])
              when 3
                proc.call(args[0], args[1], args[2])
              when 4
                proc.call(args[0], args[1], args[2], args[3], args[4])
              when 5
                proc.call(args[0], args[1], args[2], args[3], args[4], args[5])
              when 6
                proc.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6])
              when 7
                proc.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
              when 8
                proc.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
              when 9
                proc.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
              when 10
                proc.call(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10])
              end
            end
          end
        end
      end
    end
  end
end