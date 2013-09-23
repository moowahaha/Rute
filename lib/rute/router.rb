class Rute
  class Router
    def initialize
      @handler_patterns = {}
    end

    def get request_path, class_name: raise('class_name is required'), method: raise('method is required')
      assign_handler :get, request_path, class_name, method
    end

    def handler_for environment
      request = environment.request
      path = clean_path(request.path)
      handler = nil

      (@handler_patterns[request.method] || []).each do |handler_pattern|
        match_data = handler_pattern[:pattern].match(path) || next

        match_data.names.each_with_index do |name, index|
          request.parameters[name.to_sym] = URI.unescape(match_data.captures[index])
        end

        handler = handler_pattern[:handler]
        break
      end

      # TODO: 404 when no handler
      raise 'no pattern' unless handler

      handler.environment = environment
      handler
    end

    private

    def assign_handler request_method, request_path, class_name, method
      # TODO: detect duplicate patterns
      parsable_path = []
      clean_path(request_path).split('/').each do |part|
        part = part.index(':') == 0 ? part_to_regexp(part.sub(/^:/, '')) : part
        parsable_path << part
      end

      @handler_patterns[request_method] ||= []
      @handler_patterns[request_method] << {
          pattern: Regexp.new(parsable_path.join('/')),
          handler: Rute::Handler.new(class_name: class_name, method: method)
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
