class Rute
  class DefaultHandler
    def not_found request, response
      response.body = "#{response.status}: Not found"
    end
  end
end