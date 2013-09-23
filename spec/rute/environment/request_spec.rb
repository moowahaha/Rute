describe Rute::Environment::Request do
  it 'should instantiate some parameters' do
    Rute::Environment::Request::Parameters.should_receive(:new).with('a=b').and_return('some parameters')
    Rute::Environment::Request.new('QUERY_STRING' => 'a=b').parameters.should == 'some parameters'
  end

  it 'should set a path' do
    Rute::Environment::Request.new('REQUEST_PATH' => '/').path.should == '/'
  end

  it 'should have a request method' do
    Rute::Environment::Request.new('REQUEST_METHOD' => 'POST').method.should == :post
  end

  it 'should have a downcased content type' do
    Rute::Environment::Request.new('HTTP_ACCEPT' => 'TEXT/HTML').content_type.should == 'text/html'
  end
end