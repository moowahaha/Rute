Dir.glob(File.join(File.dirname(File.absolute_path(__FILE__)), '**', '*.rb')).each do |file|
  require file
end

class Rute
  attr_reader :set, :on

  def initialize &block
    caller_path = caller_locations(1, 1).first.path

    rack_builder = block.binding.eval('self')

    unless rack_builder.is_a?(Rute::TestHelper)
      raise "Caller must be a config.ru file, is #{caller_path}" unless File.basename(caller_path) == 'config.ru'
      raise "Caller must from instance of Rack::Builder, is #{rack_builder.class}" unless rack_builder.is_a?(Rack::Builder)
    end

    @set = Rute::Configuration.new
    @set.project_root = File.dirname(caller_locations(1, 1)[0].path)
    @on = Rute::Router.new @set

    instance_eval &block

    if @set.detect_file_changes
      $LOADED_FEATURES.unshift caller_path
      rack_builder.use(Rack::Reloader, 0)
    end

    @on.compile!

    Rute::MaintenanceThread.run(@set, @on)

    rack_builder.run(Rute::Application.new @on)
  end
end

