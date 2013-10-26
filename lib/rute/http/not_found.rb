class Rute
    class HTTP
      class NotFound < ::Exception
        def http_status_code() 404 end
      end
  end
end