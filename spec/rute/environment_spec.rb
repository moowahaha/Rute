describe Rute::Environment do
  it 'should instantiate a request' do
    Rute::Environment::Request.should_receive(:new).with('whatevs').and_return 'some request'
    Rute::Environment.new('whatevs').request.should == 'some request'
  end

  it 'should instantiate a response' do
    Rute::Environment::Response.should_receive(:new).and_return 'some response'
    Rute::Environment.new('whatevs').response.should == 'some response'
  end
end