describe Rute::Router do
  it 'should route a get request' do
    environment = Rute::Environment.new(
        'REQUEST_PATH' => '/reverse',
        'HTTP_ACCEPT' => 'text/html',
        'REQUEST_METHOD' => 'GET'
    )

    router = Rute::Router.new Rute::Configuration.new
    router.get '/reverse', class_name: 'Echo', method: 'reverse'

    handler = router.handler_for(environment)
    handler.method.should == 'reverse'
    handler.class_name.should == 'Echo'
  end

  it 'should setup environment with request parameters' do
    router = Rute::Router.new Rute::Configuration.new
    router.get '/reverse/:string_in_url', class_name: 'Echo', method: 'reverse'

    environment = Rute::Environment.new(
        'REQUEST_PATH' => '/reverse/something',
        'HTTP_ACCEPT' => 'text/html',
        'QUERY_STRING' => 'string_in_query=somethingelse',
        'REQUEST_METHOD' => 'GET'
    )

    router.handler_for(environment)
    environment.request.parameters[:string_in_url].should == 'something'
    environment.request.parameters[:string_in_query].should == 'somethingelse'
  end

  describe 'content types' do
    before do
      @router = Rute::Router.new Rute::Configuration.new
      @router.get '/reverse', class_name: 'Echo', method: 'reverse_with_json', content_type: 'application/json'
      @router.get '/reverse', class_name: 'Echo', method: 'reverse_with_anything'
    end

    it 'should apply the most specific route' do
      environment = Rute::Environment.new(
          'REQUEST_PATH' => '/reverse',
          'HTTP_ACCEPT' => 'application/json,text/x-json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).method.should == 'reverse_with_json'
    end

    it 'should use a fallback when supplied' do
      environment = Rute::Environment.new(
          'REQUEST_PATH' => '/reverse',
          'HTTP_ACCEPT' => 'text/html',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).method.should == 'reverse_with_anything'
    end

    it 'should respond with the appropriate content type' do
      environment = Rute::Environment.new(
          'REQUEST_PATH' => '/reverse',
          'HTTP_ACCEPT' => 'application/json,text/x-json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment)
      environment.response.headers['Content-Type'].should == 'application/json'
    end

    it 'should have a default value' do
      environment = Rute::Environment.new(
          'REQUEST_PATH' => '/reverse',
          'HTTP_ACCEPT' => 'text/html',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment)
      environment.response.headers['Content-Type'].should == 'text/html'
    end
  end

  # TODO: 404 when no handler
  # TODO: error callbacks
  # TODO: ensure error callbacks are called when something goes wrong
  # TODO: should parse complex paths
  # TODO: post request method
  # TODO: duplicate routing rule
  # TODO: make the rule definition available to called code for debug purposes
end