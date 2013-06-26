# CarrierWave for [Elasticsearch](http://elasticsearch.org)

This gem adds storage support for [Elasticsearch](http://elasticsearch.org) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

This module should work for basic uploads, but hasn't been tested with all features of carrierrwave and is very new.  The code was initially based
on [carrierwave-upyun](https://github.com/nowa/carrierwave-upyun) and [carrierwave-elasticsearch](https://github.com/motske/carrierwave-elasticsearch) but also uses ideas taken from the built in Fog storage provider.


Currently, this will only store JSON files. 


## Installation

    gem install carrierwave-elasticsearch

## Or using Bundler, in `Gemfile`

    gem 'rubberband'
    gem 'thrift'
    gem 'carrierwave-elasticsearch', :require => "carrierwave/elasticsearch"

## Configuration

You'll need to configure the Elasticsearch client in config/initializers/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :elasticsearch
  config.elasticsearch_host = 'localhost'
  config.elasticsearch_port = 9500
  config.elasticsearch_transport = :thrift
end
```

or, if you use claster of nodes

```ruby
CarrierWave.configure do |config|
  config.storage = :elasticsearch
  config.elasticsearch_nodes = [
    { host: "127.0.0.1", port: 8098 }, 
    { host: "127.0.0.1", port: 8099 }
  ]
end
```

## Usage example

Note that for your uploader, your should extend the CarrierWave::Uploader::Elasticsearch class.

```ruby
class DocumentUploader < CarrierWave::Uploader::Elasticsearch

    # If key method is not defined, Elasticsearch generated keys will be used and returned as the identifier

    def key
        original_filename
    end

    def bucket
      "my_bucket"
    end
end
```

### Using Elasticsearch generated keys ###

Because the orm record is saved before the storage object is, the orm record needs to be updated after
saving to storage if a Elasticsearch generated key is to be used as the identifier.  The CarrierWave::Uploader::Elasticsearch
class defines an :after callback to facilitate this.  This only works for ActiveRecord and is likely pretty
hacky.  Maybe someone can suggest a better way to deal with this.

## TODO ###

- Write specs.  Bad programmer.

## Contributing ##

If this is helpful to you, but isn't quite working please send me pull requests.

