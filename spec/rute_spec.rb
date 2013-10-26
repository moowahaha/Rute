require 'spec_helper'

describe Rute do
  # todo: make this load a config.ru
  before do
    @rute = Rute.new
    @rute.set.load_paths = [File.join('fixtures', 'test_classes')]
  end

  describe 'cgi parameters' do
    before do
      @rute.on.get '/reverse', class_name: 'Echo', method: 'reverse'
      @response = Rute::TestHelper.new(@rute).get(path: '/reverse', parameters: {string: 'hello'})
    end

    it 'should have a response body' do
      @response.body.should == 'olleh'
    end

    it 'should have a status code' do
      @response.status.should == 200
    end
  end

  describe 'url parameters' do
    it 'should route a request with url parameters' do
      @rute.on.get '/concatenate/:string1/:string2', class_name: 'Echo', method: 'concatenate'
      Rute::TestHelper.new(@rute).get(path: '/concatenate/hello there/to you').body.should == 'hello there to you'
    end
  end

  describe 'bad request' do
    it 'should gracefully handle internal server errors' do
      @rute.on.get '/unhandled_exception', class_name: 'Echo', method: 'method_that_throws_an_unhandled_exception'
      Rute::TestHelper.new(@rute).get(path: '/unhandled_exception').status.should == 500
    end

    it 'should handle known exceptions' do
      @rute.on.get '/handled_exception', class_name: 'Echo', method: 'method_that_throws_an_handled_exception'
      Rute::TestHelper.new(@rute).get(path: '/handled_exception').status.should == 500
    end

    it 'should handle unknown path' do
      Rute::TestHelper.new(@rute).get(path: '/unknown_path').status.should == 404
    end
  end
end
