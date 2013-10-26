class Rute
  class Router
    def initialize configuration
      @configuration = configuration
      @handler_patterns = {}
      @error_handlers = {}
      @routes = {}

      set_default_handlers
    end

    def error(error_code, class_name: raise('class_name is required'), method: raise('method is required'), content_type: nil)
      assert_route class_name: class_name, method: method

      caller = caller_locations(1, 1)[0]

      route = {
          defined_at: "#{caller.absolute_path}:#{caller.lineno}",
          handler: Rute::Handler.new(
              class_name: class_name,
              method: method
          )
      }

      @error_handlers[error_code] ||= {}
      @error_handlers[error_code][content_type || @configuration.default_content_type] = route
    end

    def get(request_path, class_name: raise('class_name is required'), method: raise('method is required'), content_type: nil)
      add_route :get, {
          request_path: request_path,
          class_name: class_name,
          method: method,
          content_type: content_type
      }
    end

    def post(request_path, class_name: raise('class_name is required'), method: raise('method is required'), content_type: nil)
      add_route :post, {
          request_path: request_path,
          class_name: class_name,
          method: method,
          content_type: content_type
      }
    end

    def put(request_path, class_name: raise('class_name is required'), method: raise('method is required'), content_type: nil)
      add_route :put, {
          request_path: request_path,
          class_name: class_name,
          method: method,
          content_type: content_type
      }
    end

    def delete(request_path, class_name: raise('class_name is required'), method: raise('method is required'), content_type: nil)
      add_route :delete, {
          request_path: request_path,
          class_name: class_name,
          method: method,
          content_type: content_type
      }
    end

    def handler_for environment
      request = environment.request
      path = clean_path(request.path)
      environment.response.headers['Content-Type'] = @configuration.default_content_type
      handler = nil

      candidate_handlers_for(request).each do |handler_pattern|
        match_data = handler_pattern[:pattern].match(path) || next

        match_data.names.each_with_index do |name, index|
          request.parameters[name.to_sym] = URI.unescape(match_data.captures[index])
        end

        handler = handler_pattern[:handler]
        environment.response.headers['Content-Type'] = handler_pattern[:content_type] if handler_pattern[:content_type]
        break
      end

      raise Rute::HTTP::NotFound unless handler

      handler.environment = environment
      handler
    end

    def compile!
      @routes.each do |request_method, routes|
        routes.each do |route|
          compile_handler_pattern request_method, route
        end
      end
    end

    def handler_for_exception exception, environment
      environment.response.status = exception.http_status_code
      environment.response.freeze_status!

      content_type = environment.response.headers['Content-Type'] ? environment.response.headers['Content-Type'] : @configuration.default_content_type

      error_handler = @error_handlers[exception.class][content_type] if @error_handlers[exception.class] && @error_handlers[exception.class][content_type]

      raise 'no handler' unless error_handler

      error_handler[:handler].environment = environment

      error_handler[:handler]
    end

    private

    def compile_handler_pattern(request_method, route)
      content_type = route[:content_type].downcase if route[:content_type]

      # TODO: detect duplicate patterns
      parsable_path = []
      path_identifier = []
      clean_path(route[:request_path]).split('/').each do |part|
        parsable_part = part.index(':') == 0 ? part_to_regexp(part.sub(/^:/, '')) : part
        identifiable_part = part.index(':') == 0 ? ':PARAMETER' : part

        parsable_path << parsable_part
        path_identifier << identifiable_part
      end

      @handler_patterns[request_method] ||= {}
      @handler_patterns[request_method][content_type] ||= []

      check_for_duplicate! @handler_patterns[request_method][content_type], route[:defined_at], path_identifier

      @handler_patterns[request_method][content_type] << {
          pattern: Regexp.new(parsable_path.join('/')),
          handler: Rute::Handler.new(
              class_name: route[:class_name],
              method: route[:method]
          ),
          content_type: content_type,
          defined_at: route[:defined_at],
          identifier: path_identifier
      }
    end

    def add_route request_method, route
      caller = caller_locations(2, 2)[0]
      route[:defined_at] = "#{caller.absolute_path}:#{caller.lineno}"

      assert_route route

      @routes[request_method] ||= []
      @routes[request_method] << route
    end

    def candidate_handlers_for request
      request_method_patterns = @handler_patterns[request.method]
      return [] if !request_method_patterns

      ((request_method_patterns[request.content_type] || []) + (request_method_patterns[nil] || [])).flatten
    end

    def part_to_regexp variable
      '(?<' + variable + '>[^\/]*)(\/|$)?'
    end

    def clean_path path
      path.gsub(/\/$/, '')
    end

    def check_for_duplicate! previous, defined_at, identifier
      duplicate_route = previous.select do |possible_duplicate|
        identifier == possible_duplicate[:identifier]
      end.first

      raise(
          Rute::Exception::DuplicateRoute,
          "Duplicate paths defined on #{duplicate_route[:defined_at]} and  #{defined_at}"
      ) if duplicate_route
    end

    def assert_route route
      klass = Module.const_get(route[:class_name])
      method = klass.instance_method(route[:method])
      if (method.parameters & [[:req, :request], [:req, :response]]).length != 2
        raise ArgumentError.new("`does_not_exist' for class `Echo' expects to receive 2 arguments: request & response")
      end
    end

    def set_default_handlers
      error Rute::HTTP::NotFound, class_name: 'Rute::DefaultHandler', method: 'not_found'
    end
  end
end
