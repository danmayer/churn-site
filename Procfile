web: bundle exec unicorn -p $PORT -c ./unicorn.rb
redis: leader --unless-port-in-use 6379 "redis-server > log/redis.log"
log: touch log/sinatra.log; tail -f log/sinatra.log
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work