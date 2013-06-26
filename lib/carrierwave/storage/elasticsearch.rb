# encoding: utf-8
require 'carrierwave'
require 'rubberband'

module CarrierWave
  module Storage

    ##
    #
    #     CarrierWave.configure do |config|
    #       config.elasticsearch_host = "http://localhost
    #       config.elasticsearch_port = 8098
    #     end
    #
    #
    class Elasticsearch < Abstract

      class Connection
        def initialize(servers, options)
          @client = ::ElasticSearch.new(servers, options)
        end

        def store(index, type, payload, headers = {})
          @client.bulk do |d|
            JSON.parse(payload).each do |msg|
              @client.index(msg, index: index, type: type, _meta: headers)
            end
          end
#          @client.index(payload, index: index, type: '')
        end

        def get(index, id)
          @client.get(id, index: index, type: '')
        end

        def delete(index, id)
          @client.delete(id, index: index, type: '')
        end
      end

      class File

        def initialize(uploader, base, index, id)
          @uploader = uploader
          @index = index
          @key = id
          @base = base
        end

        ##
        # Returns the key of the riak file
        #
        # === Returns
        #
        # [String] A filename
        #
        def key
          @key
        end

        ##
        # Lookup value for file content-type header
        #
        # === Returns
        #
        # [String] value of content-type
        #
        def content_type
          @content_type || file.content_type
        end

        ##
        # Set non-default content-type header (default is file.content_type)
        #
        # === Returns
        #
        # [String] returns new content type value
        #
        def content_type=(new_content_type)
          @content_type = new_content_type
        end

        ##
        # Return size of file body
        #
        # === Returns
        #
        # [Integer] size of file body
        #
        def size
          0 #file.raw_data.length
        end

        ##
        # Reads the contents of the file from Riak
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          file._source
        end

        ##
        # Remove the file from Riak
        #
        def delete
          begin
            elasticsearch_client.delete(@index, @key)
            true
          rescue Exception => e
            # If the file's not there, don't panic
            nil
          end
        end

        ##
        # Writes the supplied data into Riak
        #
        # === Returns
        #
        # boolean
        #
        def store(file)
          @file = elasticsearch_client.store(@index, @key, file.read, {:content_type => file.content_type, :filename => @key })
          @key = @key
          @uploader.key = @key
          true
        end

        private

          def headers
            @headers ||= {  }
          end

          def connection
            @base.connection
          end

          ##
          # lookup file
          #
          # === Returns
          #
          # [Riak::RObject] file data from remote service
          #
          def file
            @file ||= elasticsearch_client.get(@index, @key)
          end

          def elasticsearch_client
            if @elasticsearch_client
              @elasticsearch_client
            else
              @elasticsearch_client ||= CarrierWave::Storage::Elasticsearch::Connection.new(elasticsearch_options, elasticsearch_transport)
            end
          end

          def elasticsearch_options
            options = if @uploader.elasticsearch_nodes
              @uploader.elasticsearch_nodes
            else
              "#{@uploader.elasticsearch_host}:#{@uploader.elasticsearch_port}"
            end
          end

          def elasticsearch_transport
            transport = {}
            transport.merge(:transport => ::ElasticSearch::Transport::Thrift) if @uploader.elasticsearch_transport == :thrift
          end

      end

      ##
      # Store the file on Riak
      #
      # === Parameters
      #
      # [file (CarrierWave::SanitizedFile)] the file to store
      #
      # === Returns
      #
      # [CarrierWave::Storage::Riak::File] the stored file
      #
      def store!(file)
        f = CarrierWave::Storage::Elasticsearch::File.new(uploader, self, uploader.index, uploader.key)
        f.store(file)
        f
      end

      # Do something to retrieve the file
      #
      # @param [String] identifier uniquely identifies the file
      #
      # [identifier (String)] uniquely identifies the file
      #
      # === Returns
      #
      # [CarrierWave::Storage::Riak::File] the stored file
      #
      def retrieve!(key)
        CarrierWave::Storage::Elasticsearch::File.new(uploader, self, uploader.index, key)
      end

      def identifier
        uploader.key
      end

    end # CloudFiles
  end # Storage
end # CarrierWave
