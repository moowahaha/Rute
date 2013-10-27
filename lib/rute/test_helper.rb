require 'uri'

class Rute
  class TestHelper
    BASENAME = 'config.ru'
    def initialize config_ru_file
      @application = nil
      directory = File.dirname(config_ru_file)

      raise ArgumentError.new("#{config_ru_file} must have a basename of config.ru") unless File.basename(config_ru_file) == BASENAME

      FileUtils.chdir(directory) do
        eval File.read(BASENAME)
      end
    end

    def get path, parameters: {}, content_type: 'text/html'
      Rute::TestHelper::Response.new(@application.call build_env(path, parameters, content_type, 'GET'))
    end

    def run application
      @application = application
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