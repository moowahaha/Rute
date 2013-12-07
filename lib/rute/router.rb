class Rute
  class Router
    attr_accessor :handler_patterns

    def initialize configuration
      @configuration = configuration
      @handler_patterns = {}
      @error_handlers = {}
      @routes = {}

      set_default_handlers
    end

    def error error_code, route
      route[:defined_at] = caller(1, 1)
      route[:configuration] = @configuration

      assert_route_parameters route

      @error_handlers[error_code] ||= {}
      @error_handlers[error_code][route[:content_type] || @configuration.default_content_type] = route
    end

    def get request_path, route
      add_route :get, request_path, route
    end

    def post request_path, route
      add_route :post, request_path, route
    end

    def put request_path, route
      add_route :put, request_path, route
    end

    def delete request_path, route
      add_route :delete, request_path, route
    end

    def handler_for environment
      request = environment.request
      path = clean_path(request.path)
      environment.response.content_type = @configuration.default_content_type
      handler = nil

      candidate_handlers_for(request).each do |handler_pattern|
        match_data = handler_pattern[:pattern].match(path) || next

        request.parameters.accepted = handler_pattern[:accepted_parameters]

        match_data.names.each_with_index do |name, index|
          request.parameters[name] = URI.unescape(match_data.captures[index]) if handler_pattern[:accepted_parameters].nil? || handler_pattern[:accepted_parameters][name.to_sym]
        end

        handler = handler_pattern[:handler]
        environment.response.content_type = handler_pattern[:content_type] if handler_pattern[:content_type]
        break
      end

      raise Rute::HTTP::NotFound unless handler

      handler.environment = environment
      handler
    end

    def compile!
      @error_handlers.each do |error, content_types|
        content_types.each do |content_type, route|
          route[:handler] = Rute::HandlerFactory.build route
        end
      end

      @routes.each do |request_method, routes|
        routes.each do |route|
          compile_handler_pattern request_method, route
        end
      end

      optimize!
    end

    def optimize!
      @handler_patterns.each do |request_method, content_types|
        content_types.each do |content_type, routes|
          routes.sort! do |a, b|
            comp = b[:handler].invoked <=> a[:handler].invoked
            comp.zero? ? (a[:pattern].names.count <=> b[:pattern].names.count) : comp
          end
        end
      end
    end

    def handler_for_exception exception, environment
      environment.response.status = exception.http_status_code
      environment.response.freeze_status!

      content_type = environment.response.content_type ? environment.response.content_type : @configuration.default_content_type

      error_handler = @error_handlers[exception.class][content_type] if @error_handlers[exception.class] && @error_handlers[exception.class][content_type]

      raise 'no handler' unless error_handler

      error_handler[:handler].environment = environment

      error_handler[:handler]
    end

    private

    def compile_handler_pattern(request_method, route)
      content_type = route[:content_type].downcase if route[:content_type]

      path_identifier, pattern = case route[:request_path]
                                   when String
                                     request_path_from_string route[:request_path]
                                   when Regexp
                                     request_path_from_regexp route[:request_path]
                                 end

      @handler_patterns[request_method] ||= {}
      @handler_patterns[request_method][content_type] ||= []

      validate_pattern! pattern, route[:defined_at]
      check_for_duplicate! @handler_patterns[request_method][content_type], route[:defined_at], path_identifier

      @handler_patterns[request_method][content_type] << {
          pattern: pattern,
          handler: Rute::HandlerFactory.build(route),
          content_type: content_type,
          defined_at: route[:defined_at],
          identifier: path_identifier,
          accepted_parameters: route[:accepted_parameters]
      }
    end

    def request_path_from_string request_path
      parsable_path = []
      path_identifier = []
      clean_path(request_path).split('/').each do |part|
        parsable_part = part.index(':') == 0 ? part_to_regexp(part.sub(/^:/, '')) : part
        identifiable_part = part.index(':') == 0 ? ':PARAMETER' : part

        parsable_path << parsable_part
        path_identifier << identifiable_part
      end

      pattern = Regexp.new(parsable_path.join('/'))
      return path_identifier, pattern
    end

    def request_path_from_regexp request_path
      request_path_string = request_path.to_s
      request_path.names.each do |name|
        request_path_string.gsub!("<#{name}>", '<PARAMETER>')
      end

      return request_path_string, request_path
    end

    def assert_route_parameters route
      raise_accepted_parameter_exception_for route if route[:accepted_parameters] && !route[:accepted_parameters].is_a?(Array)
      raise_destination_exception_for route if route[:class] && route[:static_file]
      raise_destination_exception_for route if route[:method] && route[:static_file]
      raise_destination_exception_for route if route[:class] && !route[:method]
      raise_destination_exception_for route if !route[:class] && route[:method]
    end

    def raise_accepted_parameter_exception_for route
      raise_route_argument_exception route, 'accepted_parameters must be type of Array'
    end

    def raise_destination_exception_for route
      raise_route_argument_exception route, 'Route must specify class and method OR static_file'
    end

    def raise_route_argument_exception route, message
      exception = ArgumentError.new(message)
      exception.set_backtrace route[:defined_at]
      raise exception
    end

    def add_route request_method, request_path, route
      route[:request_path] = request_path
      route[:defined_at] = caller(2, 2)
      route[:configuration] = @configuration

      assert_route_parameters route

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

    def validate_pattern! pattern, defined_at
      unless pattern.source =~ /^\// || pattern.source == ''
        exception = Rute::Exception::InvalidRoute.new(
            "Route pattern must begin with a '/'"
        )
        exception.set_backtrace defined_at
        raise exception
      end
    end

    def check_for_duplicate! previous, defined_at, identifier
      duplicate_route = previous.select do |possible_duplicate|
        identifier == possible_duplicate[:identifier]
      end.first

      if duplicate_route
        exception = Rute::Exception::DuplicateRoute.new(
            "Path already defined at #{duplicate_route[:defined_at][0]}"
        )
        exception.set_backtrace defined_at
        raise exception
      end
    end

    def set_default_handlers
      error Rute::HTTP::NotFound, class: Rute::DefaultHandler, method: :not_found
      error Rute::HTTP::InternalServerError, class: Rute::DefaultHandler, method: :internal_server_error
    end
  end
end
