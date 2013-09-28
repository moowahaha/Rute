describe Rute::Router do
  before do
    configuration = Rute::Configuration.new
    configuration.project_root = File.join($SPEC_ROOT, 'fixtures')
    files = Rute::Files.new configuration
    files.load!
    @router = Rute::Router.new configuration
  end

  it 'should route a get request' do
    environment = Rute::Environment.new(
        'SCRIPT_NAME' => '/reverse',
        'HTTP_ACCEPT' => 'text/html',
        'REQUEST_METHOD' => 'GET'
    )

    @router.get '/reverse', class_name: 'Echo', method: 'reverse'
    @router.compile!

    handler = @router.handler_for(environment)
    handler.method.should == 'reverse'
    handler.class_name.should == 'Echo'
  end

  it 'should setup environment with request parameters' do
    @router.get '/reverse/:string_in_url', class_name: 'Echo', method: 'reverse'
    @router.compile!

    environment = Rute::Environment.new(
        'SCRIPT_NAME' => '/reverse/something',
        'HTTP_ACCEPT' => 'text/html',
        'QUERY_STRING' => 'string_in_query=somethingelse',
        'REQUEST_METHOD' => 'GET'
    )

    @router.handler_for(environment)
    environment.request.parameters[:string_in_url].should == 'something'
    environment.request.parameters[:string_in_query].should == 'somethingelse'
  end

  it 'should cope with duplicate routes' do
    @router.get '/reverse/:string_in_url', class_name: 'Echo', method: 'will never happen'
    @router.get '/reverse/:string_in_url', class_name: 'Echo', method: 'will never happen also'
    expect {@router.compile!}.to raise_error(Rute::Exception::DuplicateRoute)
  end

  describe 'content types' do
    before do
      @router.get '/reverse', class_name: 'Echo', method: 'reverse_with_json', content_type: 'application/json'
      @router.get '/reverse', class_name: 'Echo', method: 'reverse_with_anything'
      @router.compile!
    end

    it 'should apply the most specific route' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).method.should == 'reverse_with_json'
    end

    it 'should use a fallback when supplied' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'text/html',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).method.should == 'reverse_with_anything'
    end

    it 'should respond with the appropriate content type' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment)
      environment.response.headers['Content-Type'].should == 'application/json'
    end

    it 'should have a default value' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
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
  # TODO: make the rule definition available to called code for debug purposes
end