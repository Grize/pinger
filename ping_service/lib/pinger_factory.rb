# frozen_string_literal: true

class PingerFactory
  require_relative 'net_icmp_pinger'

  def initialize(ip)
    @ip = ip
  end

  def call
    NetIcmpPinger.new(@ip)
  end
end
