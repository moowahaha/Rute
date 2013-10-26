class Rute
  class TestHelper
    class Response
      attr_reader :status, :content_type, :headers, :body

      def initialize rack_response
        @status = rack_response[0]
        @headers = rack_response[1]
        @content_type = @headers['Content-Type']
        @body = rack_response[2]
      end
    end
  end
end