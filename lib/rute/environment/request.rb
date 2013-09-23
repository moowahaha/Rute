require 'rack'

class Rute
  class Environment
    class Request
      attr_reader :parameters, :path

      def initialize raw_environment
        @parameters = Rute::Environment::Request::Parameters.new(raw_environment['QUERY_STRING'])
        @path = raw_environment['REQUEST_PATH']
      end
    end
  end
end