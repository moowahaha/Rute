require 'rack'

class Rute
  class Application
    def initialize router
      @router = router
    end

    def call env
      environment = Rute::Environment.new env
      begin
        handler = @router.handler_for environment
        handler.invoke!
      rescue Rute::HTTP::Exception => e
        handler = @router.handler_for_exception e, environment
        handler.invoke!
      rescue => e
        $stderr.print e.message
        handler = @router.handler_for_exception Rute::HTTP::InternalServerError.new, environment
        handler.invoke!
      end

      response = handler.environment.response
      [response.status, response.headers, response.body]
    end
  end
end
