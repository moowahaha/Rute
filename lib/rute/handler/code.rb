class Rute
  class Handler
    class Code < Rute::Handler
      @@instantiated_classes = {}

      attr_accessor :inspectable_method, :inspectable_class

      def initialize route
        super route

        instantiate_for route

        @@instantiated_classes[@class] ||= @class.new
        @instance = @@instantiated_classes[@class]
      end

      protected

      def invoke_uncached!
        @instance.send(@method, @environment.request, @environment.response)
      end

      private

      def instantiate_for route
        klass = route[:class]
        if klass.is_a?(String)
          begin
            klass = Module.const_get(klass)
          rescue NameError
            exception = NameError.new("Class `#{klass}' is not defined")
            exception.set_backtrace @defined_at
            raise exception
          end
        end

        @defined_at = route[:defined_at]
        @inspectable_method = @method = route[:method]
        @inspectable_class = @class = klass

        unless klass.method_defined?(@method)
          exception = NameError.new("Unknown instance method `#{@method}' for class `#{klass}'")
          exception.set_backtrace @defined_at
          raise exception
        end

        method = klass.instance_method(@method)

        if (method.parameters & [[:req, :request], [:req, :response]]).length != 2
          exception = ArgumentError.new("`#{@method}' for class `#{klass}' expects to receive 2 arguments: request & response")
          exception.set_backtrace(@defined_at)
          raise exception
        end
      end
    end
  end
end