$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'rute'

rute = Rute.new

rute.set.load_paths = ['lib']
rute.set.static_paths = ['static']

rute.on.get '/', class_name: 'Car', method: 'index'
rute.on.get '/car/:registration', class_name: 'Car', methd: 'show'
rute.on.post '/car/:registration', class_name: 'Car', methd: 'update'
rute.on.error Rute::INTERNAL_SERVER_ERROR, class_name: 'Car', method: 'error'
rute.on.error Rute::NOT_FOUND, class_name: 'Car', method: 'not_found'

run rute.application

