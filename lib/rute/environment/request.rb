require 'rack'

class Rute
  class Environment
    class Request
      attr_reader :parameters, :path, :method, :content_type, :time, :uri

      def initialize raw_environment
        raw_environment['rack.input'] ||= StringIO.new
        rack_request = Rack::Request.new raw_environment
        @parameters = Rute::Environment::Request::Parameters.new(rack_request.params)
        @path = rack_request.path
        @uri = rack_request.fullpath
        @method = (rack_request.request_method || '').downcase.to_sym
        @content_type = (rack_request.content_type || '').downcase
        @time = Time.now
      end
    end
  end
end