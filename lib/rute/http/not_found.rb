class Rute
    class HTTP
      class NotFound < Rute::HTTP::Exception
        HTTP_STATUS_CODE = 404
      end
  end
end