$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'rute'

rute = Rute.new
rute.set.detect_file_changes = true
rute.set.load_paths = ['test_classes']

rute.on.get '/concatenate/:string1/', class_name: 'Echo', method: 'concatenate'
rute.on.get '/unhandled_exception', class_name: 'Echo', method: 'method_that_throws_an_unhandled_exception'
rute.on.get '/handled_exception', class_name: 'Echo', method: 'method_that_throws_an_handled_exception'

run rute.application
