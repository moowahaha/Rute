describe Rute::Configuration do
  describe 'defaults' do
    before do
      @configuration = Rute::Configuration.new
    end

    it 'should have content type' do
      @configuration.default_content_type.should == 'text/html'
    end

    it 'should have load paths to current directory' do
      @configuration.load_paths.should == ['.']
    end

    it 'should have static paths' do
      @configuration.static_paths.should == ['.']
    end

    it 'should have cache config' do
      @configuration.cache.should == {
          mechanism: Rute::Cache::Daybreak,
          config: {
              path: File.join(Dir.tmpdir, 'rute_cache.db'),
              wipe_on_restart: true,
              max_cache_entries: 512
          }
      }
    end
  end
end