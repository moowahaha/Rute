class Echo
  def reverse request, response
    response.body = request.parameters[:string].reverse
  end
end
