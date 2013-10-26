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
    @router.get '/reverse/:string_in_url', class_name: 'Echo', method: 'reverse'
    @router.get '/reverse/:string_in_url', class_name: 'Echo', method: 'reverse'
    expect { @router.compile! }.to raise_error(Rute::Exception::DuplicateRoute)
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

  describe 'verbs' do
    before do
      @router.get '/reverse', class_name: 'Echo', method: 'some_get_method'
      @router.post '/reverse', class_name: 'Echo', method: 'some_post_method'
      @router.put '/reverse', class_name: 'Echo', method: 'some_put_method'
      @router.delete '/reverse', class_name: 'Echo', method: 'some_delete_method'
      @router.compile!
    end

    it 'should get on GET request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).method.should == 'some_get_method'
    end

    it 'should post on POST request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'POST'
      )

      @router.handler_for(environment).method.should == 'some_post_method'
    end

    it 'should put on PUT request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'PUT'
      )

      @router.handler_for(environment).method.should == 'some_put_method'
    end

    it 'should delete on DELETE request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'DELETE'
      )

      @router.handler_for(environment).method.should == 'some_delete_method'
    end
  end

  describe 'non-existent destinations' do
    it 'should deal with a non-existent class' do
      @router.get '/reverse', class_name: 'DoesNotExist', method: 'who_cares'
      expect { @router.compile! }.to raise_error(NameError)
    end

    it 'should deal with a non-existent method' do
      @router.get '/reverse', class_name: 'Echo', method: 'does_not_exist'
      expect { @router.compile! }.to raise_error(NameError)
    end

    it 'should deal with a method does not accept 2 parameter' do
      @router.get '/reverse', class_name: 'Echo', method: 'method_with_too_few_parameters'
      expect { @router.compile! }.to raise_error(ArgumentError)
    end
  end

  describe 'handler_for_exception' do
    before do
      @environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'GET'
      )
    end

    describe 'default 404 handler' do
      before do
        @router.compile!
        @handler = @router.handler_for_exception(
            Rute::HTTP::NotFound.new,
            @environment
        )
      end

      it 'should give me a class' do
        @handler.class_name.should == 'Rute::DefaultHandler'
      end

      it 'should give me a method' do
        @handler.method.should == 'not_found'
      end

      it 'should give me an immutable response status' do
        expect { @handler.environment.response.status = 123 }.to raise_error(Rute::Exception::StatusCodeChangeDenied)
      end
    end

    describe 'specified 404 handler' do
      before do
        @router.error Rute::HTTP::NotFound, class_name: 'Echo', method: 'reverse'
        @router.compile!
        @handler = @router.handler_for_exception(
            Rute::HTTP::NotFound.new,
            @environment
        )
      end

      it 'should give me a class' do
        @handler.class_name.should == 'Echo'
      end

      it 'should give me a method' do
        @handler.method.should == 'reverse'
      end
    end
  end

  # TODO: allow routes to hit a static file (esp for error handlers)
  # TODO: make the rule definition available to called code for debug purposes
end