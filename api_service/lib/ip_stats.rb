# frozen_string_literal: true

require 'influxdb-client'
require 'influxdb-client-apis'
require 'pry'

class IpStats
  attr_reader :ip, :start_date, :end_date

  def initialize(ip, start_date, end_date)
    @ip = ip
    @start_date = DateTime.parse(start_date).rfc3339
    @end_date = DateTime.parse(end_date).rfc3339
  end

  def call
    query_api = influx_client.create_query_api
    result = query_api.query(query: query)
    return result.to_json if result.empty?

    result[0].records.first.values.to_json
  end

  private

  def query
    %(union(tables: [#{min_query},#{max_query},#{mean_query},#{stddev_query}])
      |> pivot(rowKey: ["_start"], columnKey: ["_field"], valueColumn: "_value")
      |> keep(columns: ["host", "mean_latency", "min_latency", "max_latency", "stddev_latency"])
    )
  end

  def base_query
    %(from(bucket:"servers")
      |> range(start: #{start_date}, stop: #{end_date})
      |> filter(fn: (r) => r["_measurement"] == "ip" and r["host"] == "#{ip}")
      |> group(columns: ["host"])
    )
  end

  def min_query
    %(#{base_query}
      |> min()
      |> set(key: "_field", value: "min_latency")
    )
  end

  def max_query
    %(#{base_query}
      |> max()
      |> set(key: "_field", value: "max_latency")
    )
  end

  def mean_query
    %(#{base_query}
      |> mean()
      |> set(key: "_field", value: "mean_latency")
    )
  end

  def stddev_query
    %(#{base_query}
      |> stddev()
      |> set(key: "_field", value: "stddev_latency")
    )
  end

  def influx_client
    InfluxDB2::Client.new(
      "https://localhost:8086",
      "wmITzNEQqb-LpNeBTIT4DRbET2OtiwBqQGhoACWNDavst9PV2qPLCI7-Lo4vlZW1hr_2yF-lVql8GR6z7BmTJQ==",
      bucket: 'servers',
      org: 'servers',
      use_ssl: false,
      precision: InfluxDB2::WritePrecision::NANOSECOND
    )
  end
end
