class Rute
  class HTTP
    class Exception < ::Exception
      def http_status_code
        self.class::HTTP_STATUS_CODE
      end
    end
  end
end