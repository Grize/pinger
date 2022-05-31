# frozen_string_literal: true

class TestPingStorage
  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def call(ip, failed, duration)
    "ip,host=#{ip},failed=#{failed} response_time=#{duration_in_ms(duration)}"
  end

  private

  def duration_in_ms(duration)
    ## FIXME => change 0 to something normal
    return 0 if duration.nil?

    (duration * 1000).round(3)
  end
end
