class Echo
  def reverse request, response
    response.body = request.parameters[:string].reverse
  end

  alias_method :reverse_with_json, :reverse
  alias_method :reverse_with_anything, :reverse

  def concatenate request, response
    response.body = request.parameters[:string1] + ' ' + request.parameters[:string2]
  end

  def some_get_method request, response
  end

  alias_method :some_post_method, :some_get_method
  alias_method :some_put_method, :some_get_method
  alias_method :some_delete_method, :some_get_method

  def method_with_too_few_parameters wtf
  end
end