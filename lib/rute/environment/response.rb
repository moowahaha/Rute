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

      def redirect_to path
        redirect 303, path
      end

      def permanently_moved_to path
        redirect 301, path
      end

      def freeze_status!
        @status_frozen = true
      end

      def status= status
        raise Rute::Exception::StatusCodeChangeDenied if @status_frozen
        @status = status
      end

      private

      def redirect status, path
        @headers['Location'] = path
        @status = status
        freeze_status!
      end
    end
  end
end