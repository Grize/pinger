# frozen_string_literal: true

require 'net/ping/icmp'

module PingerFactory
  def self.create(ip)
    Net::Ping::ICMP.new(ip)
  end
end
