require 'rack'

class Rute
  class Application
    def initialize router, files
      @router = router
      @files = files
    end

    def call env
      handler = @router.handler_for Rute::Environment.new env
      handler.invoke!
      response = handler.environment.response
      [response.status, response.headers, response.body]
    end
  end
end
