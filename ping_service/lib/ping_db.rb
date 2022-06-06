# frozen_string_literal: true

class PingDb
  attr_reader :db_connect

  def initialize(connect)
    @db_connect = connect
  end

  def ips_list
    connect.relations[:ips].where(enable: true).to_a.map(&:ip)
  end
end
