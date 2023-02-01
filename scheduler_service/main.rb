# frozen_string_literal: true

require 'redis'
require 'rom'
require 'yaml'
require_relative './lib/scheduler_db'
require_relative './lib/scheduler_redis'
require_relative './lib/scheduler'

ENV['APP_ENV'] ||= 'development'

root = File.expand_path('..', __dir__)
redis_config = YAML.load_file("#{root}scheduler_service/config/redis.yml", aliases: true)[ENV['APP_ENV']]
db_config = YAML.load_file("#{root}scheduler_service/config/database.yml", aliases: true)[ENV['APP_ENV']]
db_url = "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"

db_connection = ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user'], password: db_config['password']) do |config|
  config.gateways[:default].use_logger(Logger.new($stdout))
  config.relation(:ips) do
    schema(infer: true)
    auto_struct true
  end
end

redis_connection = Redis.new(url: redis_config['url'])

db = SchedulerDb.new(db_connection)
redis = SchedulerRedis.new(redis_connection)

Scheduler.new(db, redis).run
