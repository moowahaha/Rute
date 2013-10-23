class Rute
  class Environment
    class Response
      attr_accessor :body, :status
      attr_reader :headers

      def initialize
        @status = Rute::OK
        @headers = {}
        @body = ''
        @status_frozen = false
      end

      def freeze_status!
        @status_frozen = true
      end

      def status= status
        raise Rute::Exception::StatusCodeChangeDenied if @status_frozen
        @status = status
      end
    end
  end
end