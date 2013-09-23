describe Rute::Environment::Response do
  before do
    @response = Rute::Environment::Response.new
  end

  describe 'status' do
    it 'should have a default' do
      @response.status.should == Rute::OK
    end

    it 'should have be able to 404' do
      @response.not_found!
      @response.status.should == Rute::NOT_FOUND
    end

    it 'should be able to 500' do
      @response.internal_error!
      @response.status.should == Rute::INTERNAL_ERROR
    end
  end
end