require 'rack'

class Rute
  class Application
    def initialize configuration: raise('configuration is required'), router: raise('router is required')
      @router = router
      @configuration = configuration
    end

    def call env
      handler = @router.handler_for env
      handler.invoke!
      response = handler.environment.response
      [response.status, response.headers, response.body]
    end
  end
end
