require 'uri'

class Rute
  class TestHelper
    def initialize rute
      @application = rute.application
    end

    def get path: raise('path is required'), parameters: {}, content_type: 'text/html'
      Rute::TestHelper::Response.new(@application.call build_env(path, parameters, content_type, 'GET'))
    end

    private

    def build_env path, parameters, content_type, request_method
      {
          'QUERY_STRING' => URI.encode_www_form(parameters.map {|k, v| [k, v]}),
          'SCRIPT_NAME' => path,
          'HTTP_ACCEPT' => content_type,
          'REQUEST_METHOD' => request_method
      }
    end
  end
end