class Rute
  class Environment
    class Request
      class Parameters
        attr_accessor :accepted

        def initialize parameters
          @parameter_hash = {}

          parameters.each do |k, v|
            @parameter_hash[k.to_sym] = v
          end
        end

        def [] parameter
          if !@accepted.nil? && !@accepted.include?(parameter)
            exception = Rute::Exception::ParameterNotAccepted.new(
                "Parameter `#{parameter}' does not exist in the list of accepted_parameters"
            )
            exception.set_backtrace(caller(1, 1))
            raise exception
          end

          @parameter_hash[parameter]
        end

        def []= parameter, value
          @parameter_hash[parameter.to_sym] = value
        end
      end
    end
  end
end