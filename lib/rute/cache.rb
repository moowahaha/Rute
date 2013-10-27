class Rute
  class Cache
    class << self
      attr_accessor :config

      def clear
        ObjectSpace.each_object self do |instance|
          instance.clear
        end
      end
    end

    def clear
    end

    protected

    def destroy
      puts 'word'
    end

    def cache_key_for_request environment
      'uri:' + environment.request.uri
    end
  end
end