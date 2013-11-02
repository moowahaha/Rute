class Rute
  class MaintenanceThread
    class << self
      def run configuration, router
        cache = Rute::CacheFactory.build(configuration)
      end
    end
  end
end