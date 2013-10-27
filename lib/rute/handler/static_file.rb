require 'pathname'
require 'mimemagic'

class Rute
  class Handler
    class StaticFile
      attr_reader :path, :mime_type
      attr_accessor :environment

      def initialize route
        expand_path route
        @mime_type = MimeMagic.by_path(@path).type
      end

      def invoke!
        @environment.response.body = File.read(@path)
        @environment.response.content_type = @mime_type
      end

      private

      def expand_path route
        @path = route[:static_file]

        if Pathname.new(route[:static_file]).relative?
          @path = File.absolute_path(File.join(File.dirname(route[:defined_at].first.split(':').first), route[:static_file]))
        end

        unless File.exists?(@path)
          exception = ArgumentError.new("Cannot determine location of `#{@path}'")
          exception.set_backtrace(route[:defined_at])
          raise exception
        end
      end
    end
  end
end
