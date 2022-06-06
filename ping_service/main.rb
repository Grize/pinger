# frozen_string_literal: true

require_relative './lib/ping_daemon'
require 'rom'
require 'rom-sql'
require 'connection_pool'
require 'influxdb-client'
require 'influxdb-client-apis'
require 'yaml'
require 'pry'

root = File.expand_path('..', __dir__)
influx_config = YAML.load_file("#{root}/ping_service/config/influx_config.yml")
db_config = YAML.load_file("#{root}/ping_service/config/database.yml")[ENV['APP_ENV']]
db_url = "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"

db_connection = ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user']) do |config|
  config.relation(:ips) do
    schema(infer: true)
    auto_struct true
  end
end

influx_connection = ConnectionPool.new(size: 10, timeout: 1) do
  InfluxDB2::Client.new(influx_config['url'],
                        influx_config['token'],
                        bucket: influx_config['bucket'],
                        org: influx_config['org'],
                        use_ssl: false,
                        precision: InfluxDB2::WritePrecision::NANOSECOND)
end

influx = PingStorage.new(influx_connection)
db = PingDb.new(db_connection)

PingDaemon.new(db, influx, PingerFactory, 10).run


## TODO => планировщик
## 1) планировщик 
