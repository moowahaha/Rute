describe Rute::Handler::StaticFile do
  describe 'absolute path' do
    it 'should barf on non-existent file in absolute path' do
      expect {
        Rute::Handler::StaticFile.new(static_file: '/doesnotexist', defined_at: ['hello'])
      }.to raise_error(ArgumentError, "Cannot determine location of `/doesnotexist'")
    end

    it 'should yield a path' do
      this_file = File.absolute_path(__FILE__)
      Rute::Handler::StaticFile.new(static_file: this_file, defined_at: ['hello']).path.should == this_file
    end

    it 'should yield a mime type' do
      Rute::Handler::StaticFile.new(
          static_file: File.absolute_path(__FILE__),
          defined_at: ['hello']
      ).mime_type.should == 'application/x-ruby'
    end
  end

  describe 'relative path' do
    it 'should expand the path out' do
      Rute::Handler::StaticFile.new(
          static_file: File.basename(__FILE__),
          defined_at: ["#{__FILE__}:#{__LINE__}:blarg"]
      ).path.should == File.absolute_path(__FILE__)
    end
  end

  it 'should grab the mod time of the file' do
    Rute::Handler::StaticFile.new(
        static_file: __FILE__,
        defined_at: ['hello']
    ).mtime.should == File.mtime(__FILE__)
  end

  describe 'invoke!' do
    before do
      handler = Rute::Handler::StaticFile.new(
          static_file: File.join('..', '..', 'fixtures', 'rute_files_fixtures', 'version_1', 'static', 'some_static.txt'),
          defined_at: ["#{__FILE__}:#{__LINE__}:blarg"]
      )
      handler.environment = Rute::Environment.new({})
      handler.invoke!
      @response = handler.environment.response
    end

    it 'should yield a body' do
      @response.body.should == 'version 1'
    end

    it 'should yield a status' do
      @response.status.should == 200
    end

    it 'should yield a content type' do
      @response.headers['Content-Type'].should == 'text/plain'
    end
  end
end