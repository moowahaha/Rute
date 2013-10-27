describe Rute::CacheFactory do
  it 'should yield daybreak when daybreak is the configured cache' do
    configuration = Rute::Configuration.new
    configuration.cache = {
        mechanism: Rute::Cache::Daybreak,
        config: {
            path: File.join(Dir.tmpdir, 'rute_cache.db'),
            wipe_on_restart: true
        }
    }

    Rute::Cache::Daybreak.should_receive('config=').with(
        path: File.join(Dir.tmpdir, 'rute_cache.db'),
        wipe_on_restart: true
    )
    Rute::Cache::Daybreak.should_receive(:instance)

    Rute::CacheFactory.build(configuration)
  end
end