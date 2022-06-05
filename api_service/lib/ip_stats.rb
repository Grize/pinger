# frozen_string_literal: true

require 'influxdb-client'
require 'influxdb-client-apis'
require 'pry'

module IpStats
  def stats(ip, start_date, end_date)
    @ip = ip
    @start_date = start_date
    @end_date = end_date

    query_api = influx_client.create_query_api

    result = query_api.query(query: query)
    return result.to_json if result.empty?

    result[0].records.first.values.to_json
  end

  private

  # TODO => Rewrite query
  def query
    query_list = [min_query, max_query, mean_query, stddev_query]
    sub_queries = query_list.map { |sub_query| sub_query[:sub_query] }.join(',')

    %(union(tables: [#{sub_queries}])
      |> pivot(rowKey: ["_start"], columnKey: ["_field"], valueColumn: "_value")
      |> keep(columns: #{query_list.map { |sub_query| sub_query[:column] } << 'host'})
    )
  end

  def base_query
    %(from(bucket:"servers")
      |> range(start: #{@start_date}, stop: #{@end_date})
      |> filter(fn: (r) => r["_measurement"] == "ip" and r["host"] == "#{@ip}")
      |> group(columns: ["host"])
    )
  end

  def min_query
    sub_query = %(#{base_query} |> min() |> set(key: "_field", value: "min_latency"))

    { column: 'min_latency', sub_query: sub_query }
  end

  def max_query
    sub_query = %(#{base_query} |> max() |> set(key: "_field", value: "max_latency"))

    { column: 'max_latency', sub_query: sub_query }
  end

  def mean_query
    sub_query = %(#{base_query} |> mean() |> set(key: "_field", value: "mean_latency"))

    { column: 'mean_latency', sub_query: sub_query }
  end

  def stddev_query
    sub_query = %(#{base_query} |> stddev() |> set(key: "_field", value: "stddev_latency"))

    { column: 'stddev_latency', sub_query: sub_query }
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
