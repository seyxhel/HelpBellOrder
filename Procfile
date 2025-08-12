release: echo "Starting release phase..." && bundle exec rake db:create db:migrate db:seed && echo "Release phase complete" && ruby bin/deploy-setup
web: bundle exec puma -t 5:30 -p ${PORT:-3000} -e ${RAILS_ENV:-production}
websocket: bundle exec script/websocket-server.rb -b 0.0.0.0 -p ${WEBSOCKET_PORT:-6042} start
worker: bundle exec script/background-worker.rb start
