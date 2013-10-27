describe Rute::Application do
  before do
    response = double(Rute::Environment::Response)
    response.should_receive(:status).and_return(200)
    response.should_receive(:headers).and_return(['headers'])
    response.should_receive(:body).and_return('body')
    @environment = double(Rute::Environment)
    @environment.should_receive(:response).and_return(response)
    @handler = double(Rute::Handler)
    @router = double(Rute::Router)
    Rute::Environment.should_receive(:new).with({}).and_return(@environment)
    @application = Rute::Application.new @router
  end

  describe 'successful request' do
    it 'should work' do
      @router.should_receive(:handler_for).with(@environment).and_return(@handler)
      @handler.should_receive('invoke!')
      @handler.should_receive(:environment).and_return(@environment)
      @application.call({}).should == [200, ['headers'], 'body']
    end
  end

  describe 'bad request' do
    it 'should gracefully handle internal server errors' do
      @router.should_receive(:handler_for).with(@environment).and_return(@handler)
      @handler.should_receive('invoke!').and_raise('wat')

      @error_handler = double(Rute::Handler)
      @error_handler.should_receive('invoke!')
      @error_handler.should_receive(:environment).and_return(@environment)

      internal_server_error = double(Rute::HTTP::InternalServerError)
      Rute::HTTP::InternalServerError.should_receive(:new).and_return(internal_server_error)

      $stderr.should_receive(:print).with('wat')

      @router.should_receive(:handler_for_exception).with(
          internal_server_error,
          @environment
      ).and_return(@error_handler)

      @application.call({})
    end

    it 'should handle known exceptions' do
      an_error = Rute::HTTP::InternalServerError.new

      @router.should_receive(:handler_for).with(@environment).and_return(@handler)
      @handler.should_receive('invoke!').and_raise(an_error)

      @error_handler = double(Rute::Handler)
      @error_handler.should_receive('invoke!')
      @error_handler.should_receive(:environment).and_return(@environment)

      @router.should_receive(:handler_for_exception).with(
          an_error,
          @environment
      ).and_return(@error_handler)

      @application.call({})
    end

    it 'should handle unknown path' do
      not_found_error = Rute::HTTP::NotFound.new

      @router.should_receive(:handler_for).with(@environment).and_raise(not_found_error)

      @error_handler = double(Rute::Handler)
      @error_handler.should_receive('invoke!')
      @error_handler.should_receive(:environment).and_return(@environment)

      @router.should_receive(:handler_for_exception).with(
          not_found_error,
          @environment
      ).and_return(@error_handler)

      @application.call({})
    end
  end
end