# frozen_string_literal: true

require_relative './lib/ping_runner'
require_relative './lib/ping_storage'
require 'concurrent'
require 'connection_pool'
require 'influxdb-client'
require 'influxdb-client-apis'
require 'yaml'
require 'pry'

class PingDaemon
  attr_reader :connection, :pinger_factory, :thread_pool

  def initialize(connection, pinger_factory, pool_size)
    @connection = connection
    @pinger_factory = pinger_factory
    @thread_pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: pool_size)
  end

  def run
    storage = PingStorage.new(connection)
    loop do
      File.read('/Users/paulbarn/Documents/projects/servers_test/ping_service/tmp/ip_list.txt').split.map do |ip|
        Thread.new { PingRunner.new(storage, pinger_factory, ip).call }.join
      end
    end
  end
end

config = YAML.load_file('/Users/paulbarn/Documents/projects/servers_test/ping_service/config/influx_config.yml')
connection = ConnectionPool.new(size: 10, timeout: 1) do
  InfluxDB2::Client.new(config['url'],
                        config['token'],
                        bucket: config['bucket'],
                        org: config['org'],
                        use_ssl: false,
                        precision: InfluxDB2::WritePrecision::NANOSECOND)
end

PingDaemon.new(connection, PingerFactory, 10).run
