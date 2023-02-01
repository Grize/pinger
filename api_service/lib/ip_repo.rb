# frozen_string_literal: true

require 'rom'
require 'rom-sql'

module Repos
  class IpRepo < ROM::Repository[:ips]
    commands :create, update: :by_pk

    def by_ip(ip)
      ips.where(ip: ip).first
    end
  end
end
