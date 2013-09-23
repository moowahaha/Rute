require 'rack'

class Rute
  class Environment
    class Request
      attr_reader :parameters, :path, :method

      def initialize raw_environment
        @parameters = Rute::Environment::Request::Parameters.new(raw_environment['QUERY_STRING'])
        @path = raw_environment['REQUEST_PATH']
        @method = (raw_environment['REQUEST_METHOD'] || '').downcase.to_sym
      end
    end
  end
end