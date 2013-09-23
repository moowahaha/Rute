$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'rute'

rute = Rute.new

rute.set.load_paths = ['lib']

rute.on.get '/reverse', class_name: 'Echo', method: 'reverse', content_type: 'application/json'

run rute.application
