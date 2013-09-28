class Rute
  class Configuration
    attr_accessor :default_content_type, :detect_file_changes, :load_paths, :static_paths, :project_root

    def initialize
      @project_root = nil
      @detect_file_changes = false
      @default_content_type = 'text/html'
      @load_paths = %w{.}
      @static_paths = %w{.}
    end

    def project_root
      raise "project_root not set" unless @project_root
      @project_root
    end
  end
end