class Rute
  class Router
    def initialize configuration
      @configuration = configuration
      @handler_patterns = {}
    end

    def get request_path, class_name: raise('class_name is required'), method: raise('method is required'), content_type: nil
      assign_handler :get, request_path, class_name, method, content_type
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

      raise 'no pattern' unless handler

      handler.environment = environment
      handler
    end

    private

    def candidate_handlers_for request
      request_method_patterns = @handler_patterns[request.method]
      return [] if !request_method_patterns

      type_specific_handlers = []
      request.content_type.split(',').each do |content_type|
        type_specific_handlers << request_method_patterns[content_type] if request_method_patterns[content_type]
      end

      (type_specific_handlers + request_method_patterns[nil]).flatten
    end

    def assign_handler request_method, request_path, class_name, method, content_type
      content_type.downcase unless content_type.nil?

      # TODO: detect duplicate patterns
      parsable_path = []
      clean_path(request_path).split('/').each do |part|
        part = part.index(':') == 0 ? part_to_regexp(part.sub(/^:/, '')) : part
        parsable_path << part
      end

      @handler_patterns[request_method] ||= {}
      @handler_patterns[request_method][content_type] ||= []
      @handler_patterns[request_method][content_type] << {
          pattern: Regexp.new(parsable_path.join('/')),
          handler: Rute::Handler.new(class_name: class_name, method: method),
          content_type: content_type
      }
    end

    def part_to_regexp variable
      '(?<' + variable + '>[^\/]*)(\/|$)?'
    end

    def clean_path path
      path.gsub(/\/$/, '')
    end
  end
end
