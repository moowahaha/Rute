class Rute
  class Environment
    class Response
      attr_accessor :body
      attr_reader :status, :headers

      def initialize
        @status = Rute::OK
        @headers = {}
        @body = ''
      end

      def not_found!
        @status = Rute::NOT_FOUND
      end

      def internal_error!
        @status = Rute::INTERNAL_ERROR
      end
    end
  end
end