require 'carrierwave'
require 'rubberband'

module CarrierWave
  module Uploader
    class Elasticsearch < Base

      attr_accessor :key

      storage :elasticsearch

      if defined?(Rails)
        after :store, :updatemodel

        def updatemodel(file)
          if model.read_attribute(:"#{self.mounted_as}").nil? || model.read_attribute(:"#{self.mounted_as}") != self.key
            model.update_attribute(:"#{self.mounted_as}", self.key)
          end
        end
      end

      def inspect
        "#<#{self.class.name} key=#{key.inspect} index=#{index.inspect}>"
      end

      private

      def build_versioned_key(key, version_name)
        unless version_name.nil?
          "#{version_name}_#{key}"
        else
          key
        end

      end

      def store_versions!(new_file)
        active_versions.each { |name, v|
          v.key = build_versioned_key(key, name)
          v.store!(new_file)
        }
      end

      def remove_versions!
        versions.each { |name, v|
          v.key = build_versioned_key(key, name)
          v.remove!
        }
      end

      def retrieve_versions_from_cache!(cache_name)
        versions.each { |name, v|
          v.key = build_versioned_key(key, name)
          v.retrieve_from_cache!(cache_name)
        }
      end

      def retrieve_versions_from_store!(identifier)
        versions.each { |name, v|
          v.retrieve_from_store!(build_versioned_key(identifier, name)) }
      end
    end
  end
end
