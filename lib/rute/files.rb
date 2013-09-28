class Rute
  class Files
    def initialize configuration
      @configuration = configuration
      @libraries = {}
      @statics = {}
    end

    def load!
      load_files

      # TODO: if configuration.detect_file_changes, thread
    end

    def static_content file
      cleaned_filename = file.gsub(/^\//, '')
      return unless @statics[cleaned_filename]
      File.read(@statics[cleaned_filename]) if (@statics[cleaned_filename])
    end

    private

    def load_files
      load_libraries
      load_statics
    end

    def load_libraries
      @configuration.load_paths.each do |path|
        dir = File.join(@configuration.project_root, path)
        raise "No such directory #{path} in #{@configuration.project_root}" unless Dir.exist?(dir)
        $:.unshift dir

        Dir.chdir(dir) do
          Dir.glob(File.join('**', '*.rb')) do |file|
            reload dir, file
          end
        end
      end
    end

    def load_statics
      @statics = {}
      @configuration.static_paths.each do |path|
        dir = File.join(@configuration.project_root, path)
        raise "No such directory #{path} in #{@configuration.project_root}" unless Dir.exist?(dir)

        Dir.chdir(dir) do
          Dir.glob(File.join('**', '*')).each do |file|
            @statics[file] = File.join(dir, file)
          end
        end
      end
    end

    def reload dir, file
      mod_time = File.mtime(file)

      return if @libraries[file] && @libraries[file] == mod_time

      $LOADED_FEATURES.delete(File.join(dir, file))
      @libraries[file] = mod_time

      # dirty way to handle predefined constant warnings
      original_verbosity = $VERBOSE
      $VERBOSE = nil
      begin
        load file
      rescue => e
          raise e
      ensure
        $VERBOSE = original_verbosity
      end
    end
  end
end