release: bundle exec rake db:create db:migrate db:seed
web: bundle exec script/rails server -b 0.0.0.0 -p ${PORT:-3000}
websocket: bundle exec script/websocket-server.rb -b 0.0.0.0 -p ${WEBSOCKET_PORT:-6042} start
worker: bundle exec script/background-worker.rb start
