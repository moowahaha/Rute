require 'spec_helper'

describe Rute do
  before do
    @rute = Rute.new
    @rute.set.load_paths = [File.join('fixtures', 'test_classes')]
  end

  it 'should route a request with cgi parameters' do
    @rute.on.get '/reverse', class_name: 'Echo', method: 'reverse'
    Rute::TestHelper.new(@rute).get(path: '/reverse', parameters: {string: 'hello'}).body.should == 'olleh'
  end

  it 'should route a request with url parameters' do
    @rute.on.get '/concatenate/:string1/:string2', class_name: 'Echo', method: 'concatenate'
    Rute::TestHelper.new(@rute).get(path: '/concatenate/hello there/to you').body.should == 'hello there to you'
  end
end

# TODO: 404 when no handler
