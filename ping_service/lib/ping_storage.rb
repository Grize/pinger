# frozen_string_literal: true

class PingStorage
  attr_reader :connection_pool

  def initialize(connection_pool)
    @connection_pool = connection_pool
  end

  def call(ip, failed, duration)
    connection_pool.with do |influx_client|
      influx_client.create_write_api.write(data: create_message(ip, failed, duration))
    end
  end

  private

  def create_message(ip, failed, duration)
    InfluxDB2::Point.new(name: 'ip')
                    .add_tag('host', ip)
                    .add_tag('failed', failed)
                    .add_field('response_time', duration_in_ms(duration))
  end

  def duration_in_ms(duration)
    return 0 if duration.nil?

    (duration * 1000).round(3)
  end
end
