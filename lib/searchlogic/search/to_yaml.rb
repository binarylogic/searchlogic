module Searchlogic
  class Search
    module ToYaml
      def self.included(klass)
        klass.class_eval do
          yaml_as "tag:ruby.yaml.org,2002:class"
          include InstanceMethods
        end
      end

      module InstanceMethods
        def to_yaml( opts = {} )
          YAML::quick_emit( self, opts ) do |out|
            out.map("tag:ruby.yaml.org,2002:object:Searchlogic::Search") do |map|
              map.add('class_name', klass.name)
              map.add('current_scope', current_scope)
              map.add('conditions', conditions)
            end
          end
        end

        def yaml_initialize(taguri, attributes = {})
          self.klass = attributes["class_name"].constantize
          self.current_scope = attributes["current_scope"]
          @conditions ||= {}
          self.conditions = attributes["conditions"]
        end
      end
    end
  end
end