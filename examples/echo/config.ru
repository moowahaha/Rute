$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'rute'

rute = Rute.new
rute.set.detect_file_changes = true
rute.set.load_paths = ['lib']
rute.on.get '/reverse/:string', class_name: 'Echo', method: 'reverse'
rute.on.get '/', static_file: '/Users/shardisty/Desktop/graph.gif'

run rute.application
