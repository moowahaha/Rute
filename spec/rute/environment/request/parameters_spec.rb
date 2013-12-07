describe Rute::Environment::Request::Parameters do
  it 'should symbolize initialized parameters' do
    parameters = Rute::Environment::Request::Parameters.new('hello' => 'there')
    parameters[:hello].should == 'there'
  end

  it 'should symbolize set parameters' do
    parameters = Rute::Environment::Request::Parameters.new({})
    parameters['hello'] = 'there'
    parameters[:hello].should == 'there'
  end


  it 'should throw an exception when we are accessing an unaccepted parameter' do
    parameters = Rute::Environment::Request::Parameters.new({})
    parameters.accepted = [:hello]
    expect {
      parameters[:not_hello]
    }.to raise_error(Rute::Exception::ParameterNotAccepted, "Parameter `not_hello' does not exist in the list of accepted_parameters")
  end
end