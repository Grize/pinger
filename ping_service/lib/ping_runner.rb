# frozen_string_literal: true

require_relative 'pinger_factory'

class PingRunner
  attr_reader :storage, :ip, :factory

  def initialize(storage, factory, ip)
    @storage = storage
    @ip = ip
    @factory = factory
  end

  def call
    throw 'ip is not provided' if ip.nil?

    duration = pinger.ping
    storage.call(ip, duration.nil?, duration)
  end

  private

  def pinger
    factory.create(ip)
  end
end
