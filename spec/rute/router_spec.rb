describe Rute::Router do
  before do
    configuration = Rute::Configuration.new
    configuration.project_root = File.join($SPEC_ROOT, 'fixtures')
    @router = Rute::Router.new configuration
  end

  describe 'regex routes' do
    it 'should setup environment with request parameters' do
      @router.get /\/reverse\/(?<string_in_url>.*)/, class: Echo, method: :reverse
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
      @router.get /\/bob\/(?<something>.*)/, class: Echo, method: :reverse
      @router.get /\/bob\/(?<something_else>.*)/, class: Echo, method: :reverse
      expect { @router.compile! }.to raise_error(Rute::Exception::DuplicateRoute)
    end

    it 'should begin with a slash' do
      @router.get /bob/, class: Echo, method: :reverse
      expect { @router.compile! }.to raise_error(Rute::Exception::InvalidRoute)
    end
  end

  describe 'string routes' do
    it 'should setup environment with request parameters' do
      @router.get '/reverse/:string_in_url', class: Echo, method: :reverse
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
      @router.get '/reverse/:string_in_url', class: Echo, method: :reverse
      @router.get '/reverse/:string_in_url', class: Echo, method: :reverse
      expect { @router.compile! }.to raise_error(Rute::Exception::DuplicateRoute)
    end

    it 'should begin with a slash' do
      @router.get 'bob', class: Echo, method: :reverse
      expect { @router.compile! }.to raise_error(Rute::Exception::InvalidRoute)
    end
  end

  describe 'invalid route parameters' do
    it 'should throw an exception when we lack a class' do
      expect { @router.get '/', method: :blah }.to raise_error(ArgumentError)
    end

    it 'should throw an exception when we lack a method' do
      expect { @router.get '/', class: 'blah' }.to raise_error(ArgumentError)
    end

    it 'should throw an exception when we specify a static with a class' do
      expect { @router.get '/', static_file: '', class: '' }.to raise_error(ArgumentError)
    end

    it 'should throw an exception when we specify a static with a method' do
      expect { @router.get '/', static_file: '', method: '' }.to raise_error(ArgumentError)
    end

    it 'should throw an exception when we specify a static with a class and a method' do
      expect { @router.get '/', static_file: '', class: '', method: '' }.to raise_error(ArgumentError)
    end

    it 'should throw an exception when we lack everything' do
      expect { @router.get '/' }.to raise_error(ArgumentError)
    end
  end

  describe 'static destinations' do
    it 'should serve file from absolute path' do
      static_file = File.absolute_path(__FILE__)
      @router.get '/', static_file: static_file
      @router.compile!

      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).path.should == static_file
    end
  end

  describe 'content types' do
    before do
      @router.get '/reverse', class: Echo, method: :reverse_with_json, content_type: 'application/json'
      @router.get '/reverse', class: Echo, method: :reverse_with_anything
      @router.compile!
    end

    it 'should apply the most specific route' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).inspectable_method.should == :reverse_with_json
    end

    it 'should use a fallback when supplied' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'text/html',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).inspectable_method.should == :reverse_with_anything
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
      @router.get '/reverse', class: Echo, method: :some_get_method
      @router.post '/reverse', class: Echo, method: :some_post_method
      @router.put '/reverse', class: Echo, method: :some_put_method
      @router.delete '/reverse', class: Echo, method: :some_delete_method
      @router.compile!
    end

    it 'should get on GET request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'GET'
      )

      @router.handler_for(environment).inspectable_method.should == :some_get_method
    end

    it 'should post on POST request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'POST'
      )

      @router.handler_for(environment).inspectable_method.should == :some_post_method
    end

    it 'should put on PUT request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'PUT'
      )

      @router.handler_for(environment).inspectable_method.should == :some_put_method
    end

    it 'should delete on DELETE request' do
      environment = Rute::Environment.new(
          'SCRIPT_NAME' => '/reverse',
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'DELETE'
      )

      @router.handler_for(environment).inspectable_method.should == :some_delete_method
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
        @handler.inspectable_class.should == Rute::DefaultHandler
      end

      it 'should give me a method' do
        @handler.inspectable_method.should == :not_found
      end

      it 'should give me an immutable response status' do
        expect { @handler.environment.response.status = 123 }.to raise_error(Rute::Exception::StatusCodeChangeDenied)
      end
    end

    describe 'specified 404 handler' do
      before do
        @router.error Rute::HTTP::NotFound, class: Echo, method: :reverse
        @router.compile!
        @handler = @router.handler_for_exception(
            Rute::HTTP::NotFound.new,
            @environment
        )
      end

      it 'should give me a class' do
        @handler.inspectable_class.should == Echo
      end

      it 'should give me a method' do
        @handler.inspectable_method.should == :reverse
      end
    end

    it 'should support static files for errors' do
      static_file = File.absolute_path(__FILE__)
      @router.error Rute::HTTP::InternalServerError, static_file: static_file
      @router.compile!
      @router.handler_for_exception(
          Rute::HTTP::InternalServerError.new,
          @environment
      ).path.should == File.absolute_path(static_file)
    end
  end

  # TODO: static file trees
  # TODO: websockets
end