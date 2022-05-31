# frozen_string_literal: true

class TestPingerFactory
  class TestPinger
    def initialize(ip, value)
      @ip = ip
      @value = value
    end

    def ping
      @value
    end
  end

  def initialize(state)
    @state = state
  end

  def create(ip)
    value = @state[ip]
    TestPinger.new(ip, value)
  end
end
