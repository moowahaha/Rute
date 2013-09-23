class Rute
  class Router
    def initialize
      @routes = {}
    end

    def get request_path, class_name: raise('class_name is required'), method: raise('method is required')
      @routes[clean_path(request_path)] = Rute::Handler.new class_name: class_name, method: method
    end

    def handler_for env
      environment = Rute::Environment.new env
      handler = @routes[clean_path(environment.request.path)]
      handler.environment = environment
      handler
    end

    private

    def clean_path path
      path.gsub(/\/$/, '')
    end
  end
end