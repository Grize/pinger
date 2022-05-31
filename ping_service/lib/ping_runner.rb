# frozen_string_literal: true

class PingRunner
  require_relative 'pinger_factory'
  require_relative 'influx_client'

  attr_reader :factory, :ip

  def initialize(factory, ip)
    @factory = Kernel.const_get(factory)
    @ip = ip
  end

  def call
    return 'ip is not provided' if ip.nil?

    duration = pinger.ping

    message = if duration
                "ip,host=#{ip},failed=false response_time=#{duration_in_ms(duration)}"
              else
                "ip,host=#{ip},failed=true response_time=0"
              end

    InfluxClient.new(message).call
    message
  end

  private

  def pinger
    factory.new(ip).call
  end

  def duration_in_ms(duration)
    (duration * 1000).round(3)
  end
end
