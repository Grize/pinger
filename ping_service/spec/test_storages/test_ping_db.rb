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

  def delete_ip(ip)
    @list.delete(ip)
  end
end
