describe Rute::Environment::Request do
  it 'should instantiate some parameters' do
    Rute::Environment::Request::Parameters.should_receive(:new).with('a=b').and_return('some parameters')
    Rute::Environment::Request.new('QUERY_STRING' => 'a=b').parameters.should == 'some parameters'
  end

  it 'should set a path' do
    Rute::Environment::Request.new('REQUEST_PATH' => '/').path.should == '/'
  end
end