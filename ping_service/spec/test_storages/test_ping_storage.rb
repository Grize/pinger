# frozen_string_literal: true

class TestPingStorage
  attr_reader :connection

  def initialize(connection)
    @connection = connection
    @calls = []
  end

  def call(ip, failed, duration)
    @calls << [ip, failed, duration]
    "ip,host=#{ip},failed=#{failed} response_time=#{duration_in_ms(duration)}"
  end

  def list_calls
    @calls
  end

  private

  def duration_in_ms(duration)
    ## FIXME => change 0 to something normal
    return 0 if duration.nil?

    (duration * 1000).round(3)
  end
end
