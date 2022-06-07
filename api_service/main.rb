# frozen_string_literal: true

require 'sinatra'
require 'rom'
require 'yaml'
require_relative './lib/ip_repo'
require_relative './lib/ip_stats'
require_relative './lib/ips'

configure do
  db_config = YAML.load_file("#{settings.root}/config/database.yml")[settings.environment.to_s]
  influx_config = YAML.load_file("#{settings.root}/config/influx.yml")[settings.environment.to_s]
  db_url = "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"

  con = ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user']) do |conf|
    conf.register_relation(Relations::Ips)
  end

  set :ip_repo_instance, Repos::IpRepo.new(con)
  set :influx_connection, InfluxDB2::Client.new(
    influx_config['url'],
    influx_config['token'],
    bucket: influx_config['bucket'],
    org: influx_config['org'],
    use_ssl: false,
    precision: InfluxDB2::WritePrecision::NANOSECOND
  )
end

post '/ip' do
  request.body.rewind
  ip = JSON.parse(request.body.read)['ip']

  record = settings.ip_repo_instance.by_ip(ip)
  record.nil? ? settings.ip_repo_instance.create(ip: ip) : update_record(ip, true)
  status 201
end

delete '/ip' do
  request.body.rewind
  ip = JSON.parse(request.body.read)['ip']

  record = settings.ip_repo_instance.by_ip(ip)
  if record.nil?
    status 404
  else
    update_record(ip, false)
    status 204
  end
end

get '/statistic/:ip' do
  IpStats.stats(
    settings.influx_connection,
    params['ip'],
    parse_time(params['start_date']),
    parse_time(params['end_date'])
  )
end

def update_record(ip, value)
  settings.ip_repo_instance.update(ip, enable: value)
end

def parse_time(time)
  DateTime.parse(time).rfc3339
end
