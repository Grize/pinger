# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'rom'
require 'yaml'
require_relative './lib/ip_repo'
require_relative './lib/ip_stats'
require_relative './lib/ips'
require_relative './lib/stats_serializer'

configure do
  db_config = YAML.load_file("#{settings.root}/config/database.yml", aliases: true)[settings.environment.to_s]
  influx_config = YAML.load_file("#{settings.root}/config/influx.yml", aliases: true)[settings.environment.to_s]
  db_url = "#{db_config['adapter']}://#{db_config['host']}/#{db_config['database']}"

  con = ROM.container(:sql, db_url, port: db_config['port'], username: db_config['user'], password: db_config['password']) do |conf|
    conf.register_relation(Relations::Ips)
  end

  set :bind, '0.0.0.0'
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
  params = JSON.parse(request.body.read)
  ip = params['ip']

  record = settings.ip_repo_instance.by_ip(ip)
  record.nil? ? create_ip(params) : update_record(ip, { enable: true })
  status 201
end

delete '/ip' do
  request.body.rewind
  ip = JSON.parse(request.body.read)['ip']

  record = settings.ip_repo_instance.by_ip(ip)
  if record.nil?
    status 404
  else
    update_record(ip, { enable: false })
    status 204
  end
end

post '/ip/:ip/ping_period' do
  request.body.rewind
  body = JSON.parse(request.body.read).transform_keys(&:to_sym)

  record = settings.ip_repo_instance.by_ip(params['ip'])
  if record.nil?
    status 404
  else
    update_record(params['ip'], body)
    status 204
  end
end

get '/statistic/:ip' do
  ## TODO => return 404 on empty result

  result = IpStats.stats(
    settings.influx_connection,
    params['ip'],
    parse_time(params['start_date']),
    parse_time(params['end_date'])
  )

  json StatsSerializer.new(result).as_json
end

def update_record(ip, value)
  settings.ip_repo_instance.update(ip, **value)
end

def parse_time(time)
  DateTime.parse(time).rfc3339
end

def create_ip(params)
  ip = params['ip']

  settings.ip_repo_instance.create(ip: ip, last_ping: time_now)
end

def time_now
  DateTime.now
end
