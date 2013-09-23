class Rute
  class Handler
    attr_accessor :environment

    @@instantiated_classes = {}

    def initialize class_name: raise('class_name required'), method: raise('method name required')
      @@instantiated_classes[class_name] ||= Object::const_get(class_name).new
      @instance = @@instantiated_classes[class_name]
      @method_name = method
    end

    def invoke!
      @instance.send(@method_name, @environment.request, @environment.response)
    end
  end
end