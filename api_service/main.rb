# frozen_string_literal: true

require 'sinatra'
require 'rom'
require_relative './ip_repo'
require_relative './lib/ip_stats'
require_relative './lib/ip_write'

post '/add' do
  request.body.rewind
  data = JSON.parse request.body.read
  puts IpWrite.new(data['ip']).enable
end

delete '/delete' do
  request.body.rewind
  data = JSON.parse request.body.read
  puts IpWrite.new(data['ip']).disable
end

get '/statistic/:ip' do
  IpStats.new(params['ip'], params['start_date'], params['end_date']).call
end
