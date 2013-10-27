class Rute
  class Handler
    class Code
      attr_reader :method, :class_name
      attr_accessor :environment

      @@instantiated_classes = {}

      def initialize route
        @method = route[:method]
        @class_name = route[:class_name]
        @defined_at = route[:defined_at]

        assert

        @@instantiated_classes[class_name] ||= Object::const_get(class_name).new
        @instance = @@instantiated_classes[class_name]
      end

      def invoke!
        @instance.send(@method, @environment.request, @environment.response)
      end

      private

      def assert
        begin
          klass = Module.const_get(@class_name)
        rescue NameError
          exception = NameError.new("Class `#{@class_name}' is not defined")
          exception.set_backtrace @defined_at
          raise exception
        end

        unless Object.const_get(@class_name).method_defined?(@method)
          exception = NameError.new("Unknown instance method `#{@method}' for class `#{@class_name}'")
          exception.set_backtrace @defined_at
          raise exception
        end

        method = klass.instance_method(@method)

        if (method.parameters & [[:req, :request], [:req, :response]]).length != 2
          exception = ArgumentError.new("`#{@method}' for class `#{@class_name}' expects to receive 2 arguments: request & response")
          exception.set_backtrace(@defined_at)
          raise exception
        end
      end
    end
  end
end