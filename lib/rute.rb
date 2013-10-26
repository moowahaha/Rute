Dir.glob(File.join(File.dirname(File.absolute_path(__FILE__)), '**', '*.rb')).each do |file|
  require file
end

class Rute
  attr_reader :set, :on

  OK = 200

  def initialize
    @set = Rute::Configuration.new
    @set.project_root = File.dirname(caller_locations(1, 1)[0].path)
    @on = Rute::Router.new @set
  end

  def application
    files = Rute::Files.new @set
    files.load!
    @on.compile!
    Rute::Application.new @on, files
  end
end

