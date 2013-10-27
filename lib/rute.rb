Dir.glob(File.join(File.dirname(File.absolute_path(__FILE__)), '**', '*.rb')).each do |file|
  require file
end

class Rute
  attr_reader :set, :on

  def initialize &block
    rack_builder = block.binding.eval('self')

    @set = Rute::Configuration.new
    @set.project_root = File.dirname(caller_locations(1, 1)[0].path)
    @on = Rute::Router.new @set

    instance_eval &block
    rack_builder.use(Rack::Reloader, 0) if @set.detect_file_changes
    #files.load!
    @on.compile!

    rack_builder.run(Rute::Application.new @on)
  end
end

