# frozen_string_literal: true

require 'sinatra'
require 'rom'
require_relative './config/application'
require_relative './ip_repo'
require_relative './lib/ip_stats'
require_relative './lib/ip_write'

include IpStats

post '/add' do
  request.body.rewind
  data = JSON.parse request.body.read
  write_ip(data['ip'])
end

delete '/delete' do
  request.body.rewind
  data = JSON.parse request.body.read

  record = db.by_ip(data['ip'])
  record.nil? ? raise('Ip is not exist!') : update_record(false)

  'Ip successfully disabled!'
end

get '/statistic/:ip' do
  stats(params['ip'], parse_time(params['start_date']), parse_time(params['end_date']))
end

ApiService::Application.config

def write_ip(ip)
  record = db.by_ip(ip)
  record.nil? ? db.create(ip: ip) : update_record(true)
  'Ip successfully enabled!'
end

def update_record(value)
  db.update(ip, enable: value)
end

def parse_time(time)
  DateTime.parse(time).rfc3339
end
