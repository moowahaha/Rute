$SPEC_ROOT = File.dirname(__FILE__)

require File.join($SPEC_ROOT, '..', 'lib', 'rute.rb')

Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '**', '*.rb')).each do |file|
  require file
end
