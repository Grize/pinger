# frozen_string_literal: true

require 'rom'
require_relative '../ip_repo'
require_relative '../ips'

class IpWrite
  attr_reader :ip

  def initialize(ip)
    @ip = ip
  end

  def enable
    record = db.by_ip(ip)
    record.nil? ? db.create(ip: ip) : update_record(true)
    'Ip successfully enabled!'
  end

  def disable
    record = db.by_ip(ip)
    record.nil? ? raise('Ip is not exist!') : update_record(false)

    'Ip successfully disabled!'
  end

  private

  def db
    con = ROM.container(:sql, 'postgres://localhost/api_service_dev', port: 5432, username: "paulbarn") do |conf|
      conf.register_relation(Relations::Ips)
    end

    Repos::IpRepo.new(con)
  end

  def update_record(value)
    db.update(ip, enable: value)
  end
end
