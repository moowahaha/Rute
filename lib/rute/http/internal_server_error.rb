class Rute
    class HTTP
      class InternalServerError < Rute::HTTP::Exception
        HTTP_STATUS_CODE = 500
      end
  end
end