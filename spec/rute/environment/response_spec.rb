describe Rute::Environment::Response do
  before do
    @response = Rute::Environment::Response.new
  end

  describe 'status' do
    it 'should have a default' do
      @response.status.should == Rute::OK
    end

    it 'should throw an exception when attempting to change frozen status' do
      @response.freeze_status!
      expect { @response.status = 123 }.to raise_error(Rute::Exception::StatusCodeChangeDenied)
    end
  end
end