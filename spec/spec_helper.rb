require File.join(File.dirname(__FILE__), '..', 'lib', 'rute.rb')

Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '**', '*.rb')).each do |file|
  require file
end
