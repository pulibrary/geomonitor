module Geomonitor
  module Client
    class Base
      attr_accessor :start_time, :end_time

      # Create a Geomonitor::Client based off of a Layer
      # @param [Geomonitor::Layer]
      def initialize(layer, options = {})
        @layer = layer
        @options = options
      end

      # Elapsed tile request time in seconds
      # @return [Float]
      def elapsed_time
        @end_time - @start_time if @start_time && @end_time
      end

      private

      # Returns timeout for the external request
      # @return [Fixnum] request timeout in seconds
      def timeout
        @options[:timeout] || 10
      end
    end
  end
end
