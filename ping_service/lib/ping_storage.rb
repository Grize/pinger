# frozen_string_literal: true

class PingStorage
  attr_reader :influx_config

  def initialize(root)
    @influx_config = YAML.load_file("#{root}/ping_service/config/influx_config.yml")
    @connection_pool = connect
  end

  def call(ip, failed, duration)
    connection_pool.with do |influx_client|
      influx_client.create_write_api.write(data: create_message(ip, failed, duration))
    end
  end

  private

  def connect
    ConnectionPool.new(size: 10, timeout: 1) do
      InfluxDB2::Client.new(influx_config['url'],
                            influx_config['token'],
                            bucket: influx_config['bucket'],
                            org: influx_config['org'],
                            use_ssl: false,
                            precision: InfluxDB2::WritePrecision::NANOSECOND)
    end
  end

  def create_message(ip, failed, duration)
    "ip,host=#{ip},failed=#{failed} response_time=#{duration_in_ms(duration)}"
  end

  def duration_in_ms(duration)
    ## FIXME => change 0 to something normal
    return 0 if duration.nil?

    (duration * 1000).round(3)
  end
end
