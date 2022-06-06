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
    @counter = Hash.new(0)
  end

  def create(ip)
    value = @state[ip]
    binding.pry
    @counter[ip] = @counter[ip] + 1
    TestPinger.new(ip, value)
  end

  def counter_result
    @counter
  end
end
