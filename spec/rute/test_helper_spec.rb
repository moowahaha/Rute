require 'spec_helper'

describe Rute::TestHelper do
  describe 'get' do
    before do
      application = double(Rute::Application)
      application.should_receive(:call).with(
          'QUERY_STRING' => 'sup=%3F%2F%21', 'REQUEST_PATH' => '/', 'HTTP_ACCEPT' => 'whatevs', 'REQUEST_METHOD' => 'GET'
      ).and_return(
          [200, {'Content-Type' => 'whatevs'}, 'some response body']
      )
      rute = double(Rute)
      rute.should_receive(:application).and_return(application)

      test_helper = Rute::TestHelper.new(rute)
      @response = test_helper.get(path: '/', parameters: {'sup' => '?/!'}, content_type: 'whatevs')
    end

    it 'should have a status code' do
      @response.status.should == 200
    end

    it 'should have a content-type' do
      @response.content_type.should == 'whatevs'
    end

    it 'should have a body' do
      @response.body.should == 'some response body'
    end
  end
end