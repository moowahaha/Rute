class Rute
  class Environment
    class Request
      class Parameters
        def initialize query_string
          @parameter_hash = {}

          Rack::Utils.parse_nested_query(query_string).each do |key, value|
            @parameter_hash[key.to_sym] = value
          end
        end

        def [] parameter
          @parameter_hash[parameter]
        end

        def []= parameter, value
          @parameter_hash[parameter] = value
        end
      end
    end
  end
end