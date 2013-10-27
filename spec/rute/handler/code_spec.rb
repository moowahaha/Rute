class RuteHandlerTestClass
  def method_with_too_few_parameters
  end

  def some_method request, response
  end
end

describe Rute::Handler::Code do
  it 'should call a method for us' do
    test_class = double(RuteHandlerTestClass)
    RuteHandlerTestClass.should_receive(:new).and_return(test_class)
    environment = Rute::Environment.new({})
    test_class.should_receive(:some_method).with(environment.request, environment.response)
    handler = Rute::Handler::Code.new(class_name: 'RuteHandlerTestClass', method: 'some_method', defined_at: ['here'])
    handler.environment = environment
    handler.invoke!
  end

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
end