require "rubberband"
require "carrierwave"
require "carrierwave/storage/elasticsearch"
require "carrierwave/elasticsearch/configuration"
require "carrierwave/elasticsearch/version"

CarrierWave.configure do |config|
  config.storage_engines.merge!(:elasticsearch => "CarrierWave::Storage::Elasticsearch")
end

CarrierWave::Uploader::Base.send(:include, CarrierWave::Elasticsearch::Configuration)
require "carrierwave/uploader/elasticsearch"
