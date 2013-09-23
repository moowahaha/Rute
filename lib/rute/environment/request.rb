require 'rack'

class Rute
  class Environment
    class Request
      attr_reader :parameters, :path, :method, :content_type

      def initialize raw_environment
        raw_environment['rack.input'] ||= StringIO.new
        rack_request = Rack::Request.new raw_environment
        @parameters = Rute::Environment::Request::Parameters.new(rack_request.params)
        @path = rack_request.path
        @method = (rack_request.request_method || '').downcase.to_sym
        @content_type = (rack_request.content_type || '').downcase
      end
    end
  end
end