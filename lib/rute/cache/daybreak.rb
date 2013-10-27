require 'singleton'
require 'daybreak'

class Rute
  class Cache
    class Daybreak < Rute::Cache
      include Singleton

      def initialize
        @db = ::Daybreak::DB.new self.class.config[:path]
        clear if self.class.config[:wipe_on_restart]
        @db.compact
      end

      def clear
        @db.clear
      end

      def set_http_response environment
        @db.set! cache_key_for_request(environment),  environment.response
      end

      def http_response_for environment
        @db[cache_key_for_request(environment)]
      end
    end
  end
end