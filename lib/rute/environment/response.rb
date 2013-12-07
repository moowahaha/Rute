class Rute
  class Environment
    class Response
      attr_accessor :body, :status
      attr_reader :headers, :initialized_at

      def initialize
        @status = 200
        @headers = {}
        @body = ''
        @status_frozen = false
        @initialized_at = Time.now
      end

      def content_type= content_type
        @headers['Content-Type'] = content_type
      end

      def content_type
        @headers['Content-Type']
      end

      def redirect_to path, params = {}
        redirect 302, path, params
      end

      def permanently_moved_to path, params = {}
        redirect 301, path, params
      end

      def freeze_status!
        @status_frozen = true
      end

      def status= status
        raise Rute::Exception::StatusCodeChangeDenied if @status_frozen
        @status = status
      end

      private

      def redirect status, path, params
        @headers['Location'] = params.empty? ? path : path + '?' + URI.encode_www_form(params.map {|k, v| [k, v]})
        @status = status
        freeze_status!
      end
    end
  end
end