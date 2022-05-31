# frozen_string_literal: true

class NetIcmpPinger
  require 'net/ping/icmp'

  attr_reader :ip

  def initialize(ip)
    @ip = ip
  end

  def ping
    Net::Ping::ICMP.new(ip).ping
  end
end
