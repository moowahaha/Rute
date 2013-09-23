require 'spec_helper'

describe Rute::Application do
  before do
    @rute = Rute.new
    @rute.set.load_paths = [File.join('..', 'fixtures')]
  end

  it 'should route a request with cgi parameters' do
    @rute.on.get '/reverse', class_name: 'Echo', method: 'reverse'
    Rute::TestHelper.new(@rute).get(path: '/reverse', parameters: {string: 'hello'}).body.should == 'olleh'
  end

  it 'should route a request with url parameters' do
    @rute.on.get '/reverse/:string', class_name: 'Echo', method: 'reverse'
    Rute::TestHelper.new(@rute).get(path: '/reverse/hello%20there').body.should == 'ereht olleh'
  end
end
