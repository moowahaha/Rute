describe Rute::Cache::Daybreak do
  before do
    Rute::Cache.clear
    configuration = Rute::Configuration.new
    configuration.cache[:config][:max_cache_entries] = 2
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

  it 'should remove the least popular rows when we have too many' do
    environment_1 = Rute::Environment.new('SCRIPT_NAME' => '/1')
    environment_1.response.body = '1'
    @cache.set_http_response(environment_1)

    environment_2 = Rute::Environment.new('SCRIPT_NAME' => '/2')
    environment_2.response.body = '2'
    @cache.set_http_response(environment_2)

    environment_3 = Rute::Environment.new('SCRIPT_NAME' => '/3')
    environment_3.response.body = '3'
    @cache.set_http_response(environment_3)

    @cache.http_response_for(environment_1).should_not be_nil
    @cache.http_response_for(environment_3).should_not be_nil

    @cache.vacuum!

    @cache.http_response_for(environment_2).should be_nil
  end
end