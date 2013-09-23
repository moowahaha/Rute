class Rute
  class Environment
    class Request
      class Parameters
        def initialize parameters
          @parameter_hash = {}

          parameters.each do |k, v|
            @parameter_hash[k.to_sym] = v
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