module Geomonitor
  module Client
    class Iiif < Geomonitor::Client::Base

      # Starts a response, it's timer, and then creates a Geomonitor::Repsponse
      # @return [Geomonitor::Response]
      def create_response
        @start_time = Time.now
        begin
          response = grab_iiif_document
        rescue Geomonitor::Exceptions::IiifDocumentGrabFailed => error
          response = error
        end
        @end_time = Time.now
        Geomonitor::Response.new(response)
      end

      # url used for iiif doc request
      # @return [String]
      def url
        @layer.layername
      end

      # Initiates tile request from a remote WMS server. Will catch
      # Faraday::Error::ConnectionFailed and Faraday::Error::TimeoutError
      # @return [Faraday::Request] returns a Faraday::Request object
      def grab_iiif_document
        conn = Faraday.new(url: url)
        conn.get do |request|
          request.options = {
            timeout: timeout,
            open_timeout: timeout
          }
        end
      rescue Faraday::Error::ConnectionFailed
        raise Geomonitor::Exceptions::IiifDocumentGrabFailed, message: 'Connection failed', url: conn.url_prefix.to_s
      rescue Faraday::Error::TimeoutError
        raise Geomonitor::Exceptions::IiifDocumentGrabFailed, message: 'Connection timeout', url: conn.url_prefix.to_s
      end
    end
  end
end
