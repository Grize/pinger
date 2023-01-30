# frozen_string_literal: true

class PingDb
  attr_reader :db_connect

  def initialize(connection)
    @db_connect = connection
  end

  def update_last_ping(ip)
    db_connect.relation[:ips].first(ip: ip).update(last_ping: Time.now)
  end

  def list_ips
    db_connect.relations[:ips].where(enable: true).to_a.map(&:ip)
  end
end
