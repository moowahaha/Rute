describe Rute::TestHelper do
  before do
    Object.const_set('MockApplication', Class.new) unless defined?(MockApplication)
    @application = double(MockApplication)
    MockApplication.stub(:new).and_return(@application)

    FileUtils.should_receive(:chdir).with('/tmp').and_yield
    File.should_receive(:read).with('config.ru').and_return("run MockApplication.new")
    @helper = Rute::TestHelper.new('/tmp/config.ru')
  end

  describe 'GET' do
    before do
      @application.should_receive(:call).with(
          'QUERY_STRING' => 'param=some+val',
          'SCRIPT_NAME' => '/',
          'HTTP_ACCEPT' => 'text/html',
          'REQUEST_METHOD' => 'GET'
      ).and_return([
          200,
          {'Content-Type' => 'whatevs'},
          'some body'
      ])

      @response = @helper.get('/', parameters: {param: 'some val'})
    end

    it 'should yield a status code' do
      @response.status.should == 200
    end

    it 'should yield headers' do
      @response.headers.should == {'Content-Type' => 'whatevs'}
    end

    it 'should yield a content type' do
      @response.content_type.should == 'whatevs'
    end

    it 'should yield a body' do
      @response.body.should == 'some body'
    end
  end
end