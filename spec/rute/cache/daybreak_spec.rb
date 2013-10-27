describe Rute::Cache::Daybreak do
  before do
    Rute::Cache.clear
    configuration = Rute::Configuration.new
    configuration.cache[:config][:path] = File.join(Dir.tmpdir, 'rute_test.db')
    Rute::Cache::Daybreak.config = configuration.cache[:config]
    @cache = Rute::Cache::Daybreak.instance
  end

  it 'should be able to store and retrieve a response' do
    environment = Rute::Environment.new('QUERY_STRING' => 'a=b', 'SCRIPT_NAME' => '/blah')
    environment.response.body = 'blaaarg'
    @cache.set_http_response(environment)
    @cache.http_response_for(environment).body.should == 'blaaarg'
  end

  it 'should clear out when asked' do
    environment = Rute::Environment.new('QUERY_STRING' => 'a=b', 'SCRIPT_NAME' => '/blah')
    environment.response.body = 'blaaarg'
    @cache.set_http_response(environment)
    Rute::Cache.clear
    @cache.http_response_for(environment).should be_nil
  end
end