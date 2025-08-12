release: bundle exec rake db:create db:migrate db:seed && ruby bin/deploy-setup
web: bundle exec puma -C config/puma.rb
websocket: bundle exec script/websocket-server.rb -b 0.0.0.0 -p ${WEBSOCKET_PORT:-6042} start
worker: bundle exec script/background-worker.rb start
