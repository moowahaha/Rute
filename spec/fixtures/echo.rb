class Echo
  def reverse request, response
    response.body = request.parameters[:string].reverse
  end

  def concatenate request, response
    response.body = request.parameters[:string1] + ' ' + request.parameters[:string2]
  end
end