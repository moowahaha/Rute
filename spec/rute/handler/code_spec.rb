class RuteHandlerTestClass
  class << self
    attr_accessor :cache_test_value
  end

  def method_with_too_few_parameters
  end

  def some_method request, response
  end

  def cache_test_method request, response
    response.body = self.class.cache_test_value
  end
end

describe Rute::Handler::Code do
  describe 'non-existent destinations' do
    it 'should deal with a non-existent class' do
      expect {
        Rute::Handler::Code.new(
            class_name: 'DoesNotExist',
            method: 'who_cares',
            defined_at: ['here']
        )
      }.to raise_error(NameError, "Class `DoesNotExist' is not defined")
    end

    it 'should deal with a non-existent method' do
      expect {
        Rute::Handler::Code.new(
            class_name: 'RuteHandlerTestClass',
            method: 'does_not_exist',
            defined_at: ['here']
        )
      }.to raise_error(NameError, "Unknown instance method `does_not_exist' for class `RuteHandlerTestClass'")
    end

    it 'should deal with a method does not accept 2 parameter' do
      expect {
        Rute::Handler::Code.new(
            class_name: 'RuteHandlerTestClass',
            method: 'method_with_too_few_parameters',
            defined_at: ['here']
        )
      }.to raise_error(ArgumentError, "`method_with_too_few_parameters' for class `RuteHandlerTestClass' expects to receive 2 arguments: request & response")
    end
  end

  describe 'caching' do
    before do
      Rute::Cache.clear
      configuration = Rute::Configuration.new
      configuration.cache[:config][:path] = File.join(Dir.tmpdir, 'rute_test.db')

      @handler = Rute::Handler::Code.new(
          class_name: 'RuteHandlerTestClass',
          method: 'cache_test_method',
          defined_at: ['here'],
          configuration: configuration,
          cache: true
      )

      RuteHandlerTestClass.cache_test_value = 'we will see this'
      @handler.environment = Rute::Environment.new('QUERY_STRING' => 'a=b', 'SCRIPT_NAME' => '/blah')
      @handler.invoke!
    end

    it 'should re-serve the same response to the same request' do
      @handler.environment = Rute::Environment.new('QUERY_STRING' => 'a=b', 'SCRIPT_NAME' => '/blah')
      RuteHandlerTestClass.cache_test_value = 'we will NEVER see this'
      @handler.invoke!
      @handler.environment.response.body.should == 'we will see this'
    end

    it 'should not re-serve content for different url' do
      @handler.environment = Rute::Environment.new('QUERY_STRING' => 'a=somethingelse', 'SCRIPT_NAME' => '/blah')
      RuteHandlerTestClass.cache_test_value = 'we will see this change'
      @handler.invoke!
      @handler.environment.response.body.should == 'we will see this change'
    end
  end
end