# frozen_string_literal: true

require 'sinatra'

post '/add' do
  request.body.rewind
  data = JSON.parse request.body.read
  puts IpService.new(data['ip']).add
end

delete '/delete' do
  request.body.rewind
  data = JSON.parse request.body.read
  puts IpService.new(data['ip']).delete
end

get '/statistic/:ip' do
  puts IpStatistic.new(params['ip'], params['start_date'], params['end_date']).call
end

class IpService
  attr_reader :ip

  def initialize(ip)
    @ip = ip
  end

  def add
    "You add #{ip}"
  end

  def delete
    "You delete #{ip}"
  end
end

class IpStatistic
  attr_reader :ip, :start_date, :end_date

  def initialize(ip, start_date, end_date)
    @ip = ip
    @start_date = start_date
    @end_date = end_date
  end

  def call
    "#{ip} for #{start_date}-#{end_date}"
  end
end
