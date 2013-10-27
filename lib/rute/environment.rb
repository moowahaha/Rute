class Rute
  class Environment
    attr_accessor :request, :response

    def initialize raw_environment
      @request = Rute::Environment::Request.new raw_environment
      @response = Rute::Environment::Response.new
    end
  end
end