describe Rute do
  # todo: make this load a config.ru
  before do
    @helper = Rute::TestHelper.new(File.join(File.dirname(__FILE__), 'fixtures', 'config.ru'))
  end

  describe 'routing with parameters' do
    before do
      @response = @helper.get('/concatenate/hello%20there', parameters: {string2: 'to you'})
    end

    it 'should have a response body' do
      @response.body.should == 'hello there to you'
    end

    it 'should have a status code' do
      @response.status.should == 200
    end
  end

  describe 'bad request' do
    it 'should gracefully handle internal server errors' do
      @helper.get(path: '/unhandled_exception').status.should == 500
    end

    it 'should handle known exceptions' do
      @helper.get(path: '/handled_exception').status.should == 500
    end

    it 'should handle unknown path' do
      response = @helper.get(path: '/unknown_path')
      response.status.should == 404
      response.body.should == '404: Not found'
    end
  end
end
