$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'rute'

Rute.new do
  on.get '/concatenate/:string1/', class: Echo, method: 'concatenate'
  on.get '/unhandled_exception', class: Echo, method: 'method_that_throws_an_unhandled_exception'
  on.get '/handled_exception', class: Echo, method: 'method_that_throws_an_handled_exception'
  on.get '/static_file', static_file: File.join('rute_files_fixtures', 'version_1', 'static', 'some_static.txt')
end
