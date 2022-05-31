# frozen_string_literal: true

module TestPingerFactory
  class TestPinger
    def initialize(ip)
      @ip = ip
    end

    def ping
      0.40265
    end
  end

  def self.create(ip)
    TestPinger.new(ip)
  end
end
