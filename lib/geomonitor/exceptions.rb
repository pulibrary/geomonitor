module Geomonitor
  module Exceptions
    class TileGrabFailed < StandardError
      def initialize(options = {})
        @options = options
      end

      ##
      # Accessor for url option
      # @return [String]
      def request_url
        @options[:url].to_s
      end
    end
    class IiifDocumentGrabFailed < StandardError
      def initialize(options = {})
        @options = options
      end

      ##
      # Accessor for url option
      # @return [String]
      def request_url
        @options[:url].to_s
      end
    end
    class NoDocumentFound < StandardError
    end
  end
end
