# frozen_string_literal: true

class TestPingDb
  def initialize(list)
    @list = list
  end

  def list_ips
    @list
  end

  def add_ip(ip)
    @list << ip
  end
end
