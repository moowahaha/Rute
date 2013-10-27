class Rute
  class CacheFactory
    def self.build configuration
      raise ArgumentError.new('Cache must have :mechanism specified') unless configuration.cache[:mechanism]
      mechanism = configuration.cache[:mechanism].is_a?(Class) ? configuration.cache[:mechanism] : Module.const_get(configuration.cache[:mechanism])
      mechanism.config = configuration.cache[:config]
      mechanism.instance
    end
  end
end