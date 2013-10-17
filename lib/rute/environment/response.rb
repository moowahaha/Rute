class Rute
  class Environment
    class Response
      attr_accessor :body, :status
      attr_reader :headers

      def initialize
        @status = Rute::OK
        @headers = {}
        @body = ''
      end
    end
  end
end