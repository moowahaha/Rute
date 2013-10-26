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

  describe 'redirect_to' do
    before do
      @response.redirect_to 'http://www.blah.com'
    end

    it 'should set the location header' do
      @response.headers['Location'].should == 'http://www.blah.com'
    end

    it 'should set an http status of 303' do
      @response.status.should == 303
    end

    it 'should freeze the status' do
      expect {@response.status = 123}.to raise_error(Rute::Exception::StatusCodeChangeDenied)
    end
  end

  describe 'permanently_moved_to' do
    before do
      @response.permanently_moved_to 'http://www.blah.com'
    end

    it 'should set the location header' do
      @response.headers['Location'].should == 'http://www.blah.com'
    end

    it 'should set an http status of 303' do
      @response.status.should == 301
    end

    it 'should freeze the status' do
      expect {@response.status = 123}.to raise_error(Rute::Exception::StatusCodeChangeDenied)
    end
  end
end