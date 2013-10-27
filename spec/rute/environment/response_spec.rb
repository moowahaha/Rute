describe Rute::Environment::Response do
  before do
    @response = Rute::Environment::Response.new
  end

  describe 'status' do
    it 'should have a default' do
      @response.status.should == 200
    end

    it 'should throw an exception when attempting to change frozen status' do
      @response.freeze_status!
      expect { @response.status = 123 }.to raise_error(Rute::Exception::StatusCodeChangeDenied)
    end
  end

  describe 'content_type' do
    before do
      @response.content_type = 'blah'
    end

    it 'should set the Content-Type header' do
      @response.headers['Content-Type'].should == 'blah'
    end

    it 'should have an accessor' do
      @response.content_type.should == 'blah'
    end
  end

  describe 'redirect_to' do
    before do
      @response.redirect_to 'http://www.blah.com', {name: 'bob smith'}
    end

    it 'should set the location header' do
      @response.headers['Location'].should == 'http://www.blah.com?name=bob+smith'
    end

    it 'should set an http status of 302' do
      @response.status.should == 302
    end

    it 'should freeze the status' do
      expect {@response.status = 123}.to raise_error(Rute::Exception::StatusCodeChangeDenied)
    end
  end

  describe 'permanently_moved_to' do
    before do
      @response.permanently_moved_to 'http://www.blah.com', {name: 'bob smith'}
    end

    it 'should set the location header' do
      @response.headers['Location'].should == 'http://www.blah.com?name=bob+smith'
    end

    it 'should set an http status of 301' do
      @response.status.should == 301
    end

    it 'should freeze the status' do
      expect {@response.status = 123}.to raise_error(Rute::Exception::StatusCodeChangeDenied)
    end
  end
end