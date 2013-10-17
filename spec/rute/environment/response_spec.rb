describe Rute::Environment::Response do
  before do
    @response = Rute::Environment::Response.new
  end

  describe 'status' do
    it 'should have a default' do
      @response.status.should == Rute::OK
    end
  end
end