class Rute
  class TestHelper
    class Response
      attr_reader :status, :content_type, :body

      def initialize rack_response
        @status = rack_response[0]
        @content_type = rack_response[1]['Content-Type']
        @body = rack_response[2]
      end
    end
  end
end