class RuteHandlerTestClass
end

describe Rute::Handler do
  it 'should call a method for us' do
    test_class = double(RuteHandlerTestClass)
    RuteHandlerTestClass.should_receive(:new).and_return(test_class)
    environment = Rute::Environment.new({})
    test_class.should_receive(:some_method).with(environment.request, environment.response)
    handler = Rute::Handler.new(class_name: 'RuteHandlerTestClass', method: 'some_method')
    handler.environment = environment
    handler.invoke!
  end
end