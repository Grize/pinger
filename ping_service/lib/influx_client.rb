# frozen_string_literal: true

require 'influxdb-client'
require 'influxdb-client-apis'
require 'yaml'

class InfluxClient
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def call
    write_api = client.create_write_api
    write_api.write(data: data, precision: InfluxDB2::WritePrecision::NANOSECOND)
  end

  private

  def config
    YAML.load_file('/Users/paulbarn/Documents/projects/servers_test/ping_service/config/influx_config.yml')
  end

  def client
    InfluxDB2::Client.new(url, token, bucket: bucket, org: org, use_ssl: false)
  end

  def url
    config['url']
  end

  def token
    config['token']
  end

  def bucket
    config['bucket']
  end

  def org
    config['org']
  end
end
