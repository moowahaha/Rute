class Rute
  class Configuration
    attr_accessor :default_content_type

    def initialize
      @default_content_type = 'text/html'
    end

    def static_paths= paths = []
      # TODO: this
    end

    def load_paths= paths = []
      caller_path = File.dirname(caller_locations(1, 1)[0].path)
      paths.each do |path|
        dir = File.join(caller_path, path)
        raise "No such directory #{path} in #{caller_path}" unless Dir.exist?(dir)
        $:.unshift dir

        Dir.glob(File.join(dir, '**', '*.rb')) do |file|
          require file
        end
      end
    end
  end
end