class Rute
  class HandlerFactory
    def self.build route
      route[:static_file] ? Rute::Handler::StaticFile.new(route) : Rute::Handler::Code.new(route)
    end
  end
end