describe Rute::Router do
  it 'should route a request' do
    response = double(Rute::Environment::Response)
    response.should_receive(:path).and_return('/reverse')
    environment = double(Rute::Environment)
    environment.should_receive(:request).and_return(response)
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