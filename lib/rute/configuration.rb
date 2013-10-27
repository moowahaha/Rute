class Rute
  class Configuration
    attr_accessor :default_content_type, :detect_file_changes, :load_paths, :static_paths, :project_root, :cache

    def initialize
      @project_root = nil
      @detect_file_changes = false
      @default_content_type = 'text/html'
      @load_paths = %w{.}
      @static_paths = %w{.}
      @cache = {
          mechanism: Rute::Cache::Daybreak,
          config: {
            path: File.join(Dir.tmpdir, 'rute_cache.db'),
            wipe_on_restart: true
          }
      }
    end

    def project_root
      raise "project_root not set" unless @project_root
      @project_root
    end
  end
end