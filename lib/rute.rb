Dir.glob(File.join(File.dirname(File.absolute_path(__FILE__)), '**', '*.rb')).each do |file|
  require file
end

class Rute
  attr_reader :set, :on

  OK = 200
  INTERNAL_ERROR = 500
  NOT_FOUND = 404

  def initialize
    @set = Rute::Configuration.new
    @on = Rute::Router.new @set
  end

  def application
    Rute::Application.new @on
  end
end

