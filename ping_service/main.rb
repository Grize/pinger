# frozen_string_literal: true

require_relative './lib/ping_daemon'
require_relative './lib/ping_db'
require_relative './lib/ping_storage'
require 'rom'
require 'rom-sql'
require 'connection_pool'
require 'influxdb-client'
require 'influxdb-client-apis'
require 'yaml'
require 'pry'

root = File.expand_path('..', __dir__)
influx_config = YAML.load_file("#{root}/ping_service/config/influx_config.yml")
db_connection = PingDb.new(root).connect
influx_connection = PingStorage.new(root)

PingDaemon.new(db_connection, influx_connection, PingerFactory, 10).run


## TODO => планировщик
## 1) планировщик 
