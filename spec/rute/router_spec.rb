describe Rute::Router do
  it 'should route a request' do
    environment = Rute::Environment.new(
        'REQUEST_PATH' => '/reverse',
        'HTTP_ACCEPT' => 'text/html',
        'REQUEST_METHOD' => 'GET'
    )

    handler = double(Rute::Handler)
    handler.should_receive('environment=').with(environment)
    Rute::Handler.should_receive(:new).with(class_name: 'Echo', method: 'reverse').and_return(handler)

    router = Rute::Router.new
    router.get '/reverse', class_name: 'Echo', method: 'reverse'

    router.handler_for(environment).should == handler
  end

  # TODO: 404 when no handler
  # TODO: should parse complex paths
  # TODO: post request method
  # TODO: duplicate routing rule
  # TODO: content-type magic
end