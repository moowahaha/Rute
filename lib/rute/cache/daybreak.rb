require 'singleton'
require 'daybreak'

class Rute
  class Cache
    class Daybreak < Rute::Cache
      include Singleton

      def initialize
        @db = ::Daybreak::DB.new self.class.config[:path]
        clear if self.class.config[:wipe_on_restart]
        vacuum!
        @db.compact
      end

      def clear
        @db.clear
      end

      def set_http_response environment
        @db.set! cache_key_for_request(environment), {response: environment.response, fetched_count: 0}
      end

      def http_response_for environment
        key = cache_key_for_request(environment)
        cache_row = @db[key] || return
        cache_row[:fetched_count] += 1
        @db[key] = cache_row
        cache_row[:response]
      end

      def vacuum!
        max_cache_entries = self.class.config[:max_cache_entries]
        if max_cache_entries && @db.length > max_cache_entries
          keys = @db.sort do |a, b|
            b[1][:fetched_count] <=> a[1][:fetched_count]
          end.map do |a|
            a[0]
          end

          keys[max_cache_entries - 1..-1].each do |key|
            @db.delete(key)
          end
        end
      end
    end
  end
end