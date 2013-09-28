require 'tmpdir'

describe Rute::Files do
  def move_files version
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'fixtures', 'rute_files_fixtures', version.to_s, '*')).each do |file|
      FileUtils.cp_r(
          file,
          @tmp_dir
      )
    end
  end

  before do
    @tmp_dir = Dir.mktmpdir

    @configuration = Rute::Configuration.new
    @configuration.project_root = @tmp_dir
    @configuration.load_paths = ['lib']
    @configuration.static_paths = ['static']

    @files = Rute::Files.new @configuration
  end

  after do
    FileUtils.rm_rf(@tmp_dir)
  end

  describe 'initial load' do
    before do
      move_files(:version_1)
    end

    it 'should not have access to anything we have not yet loaded' do
      defined?(SomeLib).should be_nil
    end

    it 'should load source files' do
      @files.load!
      defined?(SomeLib).should_not be_nil
      SomeLib::VERSION.should == 1
    end

    it 'should load static files' do
      @files.load!
      @files.static_content('some_static.txt').should == 'version 1'
      @files.static_content('/some_static.txt').should == 'version 1'
    end

    it 'should not load hidden static files' do
      @files.load!
      @files.static_content('.some_hidden_file').should be_nil
    end

    it 'should reload' do
      FileUtils.touch [File.join(@tmp_dir, 'lib', 'some_lib.rb')], mtime: Time.now - 10
      @files.load!
      move_files(:version_2)
      @files.load!
      SomeLib::VERSION.should == 2
    end
  end
end