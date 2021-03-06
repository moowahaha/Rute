class Rute
  class Handler
    attr_accessor :environment
    attr_reader :invoked

    def initialize route
      @invoked = 0
      @cache = Rute::CacheFactory.build(route[:configuration]) if route[:cache]
    end

    def invoke!
      raise "`environment' attribute not set, cannot invoke" unless self.environment
      environment = self.environment

      @invoked += 1

      # todo: clean this up, it's a motherfucking mess
      if @cache
        response = @cache.http_response_for(environment)

        if response
          environment.response = response
        else
          self.invoke_uncached!
          @cache.set_http_response(environment)
        end
      else
        self.invoke_uncached!
      end
    end
  end
end
