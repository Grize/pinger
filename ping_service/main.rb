# frozen_string_literal: true

require_relative './lib/ping_runner'
require_relative './lib/ping_storage'
require 'rom'
require 'rom-sql'
require 'concurrent'
require 'connection_pool'
require 'influxdb-client'
require 'influxdb-client-apis'
require 'yaml'
require 'pry'

class PingDaemon
  attr_reader :db, :influx, :pinger_factory, :thread_pool

  def initialize(db, influx, pinger_factory, pool_size)
    @db = db
    @influx = influx
    @pinger_factory = pinger_factory
    @thread_pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: pool_size)
  end

  def run
    storage = PingStorage.new(influx)
    loop do
      ips = db.relations[:ips].where(enable: true).to_a.map(&:ip)
      ips.each do |ip|
        Thread.new { PingRunner.new(storage, pinger_factory, ip).call }.join
      end
    end
  end
end

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

PingDaemon.new(db_connection, influx_connection, PingerFactory, 10).run


## TODO => планировщик
## 1) планировщик 
