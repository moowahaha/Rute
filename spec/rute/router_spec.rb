describe Rute::Router do
  it 'should route a request' do
    request = double(Rute::Environment::Request)
    request.should_receive(:path).and_return('/reverse')
    request.should_receive(:method).and_return(:get)
    environment = double(Rute::Environment)
    environment.should_receive(:request).and_return(request)
    Rute::Environment.should_receive(:new).with(
        'REQUEST_PATH' => '/reverse',
        'HTTP_ACCEPT' => 'text/html',
        'REQUEST_METHOD' => 'GET'
    ).and_return(environment)

    handler = double(Rute::Handler)
    handler.should_receive('environment=').with(environment)
    Rute::Handler.should_receive(:new).with(class_name: 'Echo', method: 'reverse').and_return(handler)

    router = Rute::Router.new
    router.get '/reverse', class_name: 'Echo', method: 'reverse'

    router.handler_for(
        'REQUEST_PATH' => '/reverse',
        'HTTP_ACCEPT' => 'text/html',
        'REQUEST_METHOD' => 'GET'
    ).should == handler
  end
end