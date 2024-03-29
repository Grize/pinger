# frozen_string_literal: true

require_relative './lib/ping_daemon'
require_relative './lib/ping_db'
require_relative './lib/ping_redis'
require 'rom'
require 'rom-sql'
require 'connection_pool'
require 'influxdb-client'
require 'influxdb-client-apis'
require 'yaml'
require 'pry'
require 'redis'

ENV['APP_ENV'] ||= 'development'

root = File.expand_path('..', __dir__)
influx_config = YAML.load_file("#{root}/ping_service/config/influx_config.yml", aliases: true)[ENV['APP_ENV']]
db_config = YAML.load_file("#{root}/ping_service/config/database.yml", aliases: true)[ENV['APP_ENV']]
db_url = "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"
redis_config = YAML.load_file("#{root}/ping_service/config/redis.yml", aliases: true)[ENV['APP_ENV']]

db_connection = ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user'], password: db_config['password']) do |config|
  config.gateways[:default].use_logger(Logger.new($stdout))
  config.relation(:ips) do
    schema(infer: true)
    auto_struct true
  end
end

influx_connection = ConnectionPool.new(size: 2, timeout: 1) do
  InfluxDB2::Client.new(influx_config['url'],
                        influx_config['token'],
                        bucket: influx_config['bucket'],
                        org: influx_config['org'],
                        use_ssl: false,
                        precision: InfluxDB2::WritePrecision::NANOSECOND)
end

redis_connection = Redis.new(url: redis_config['url'])

influx = PingStorage.new(influx_connection)
db = PingDb.new(db_connection)
redis = PingRedis.new(redis_connection)

PingDaemon.new(db, influx, redis, PingerFactory, 10).run.wait!
