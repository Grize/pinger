# frozen_string_literal: true

class TestPingerFactory
  class TestPinger
    def initialize(value)
      @value = value
    end

    def ping
      @value
    end
  end

  def initialize(state)
    @state = state
    @counter = Hash.new(0)
  end

  def create(ip)
    value = @state[ip]
    @counter[ip] += 1
    TestPinger.new(value)
  end

  def add_ip(ip, value)
    @state[ip] = value
  end

  def counter_result
    @counter
  end
end
