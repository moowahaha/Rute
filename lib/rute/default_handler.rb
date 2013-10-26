class Rute
  class DefaultHandler
    def not_found request, response
      response.body = "#{response.status}: Not found"
    end

    def internal_server_error request, response
      response.body = "#{response.status}: Internal Server Error"
    end
  end
end