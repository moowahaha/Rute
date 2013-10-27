$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'rute'

require './lib/echo'

Rute.new do
  set.detect_file_changes = true
  on.get '/reverse/:string', class: Echo, method: :reverse
  on.get '/', static_file: '/Users/shardisty/Desktop/graph.gif'
end
