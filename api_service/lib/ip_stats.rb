# frozen_string_literal: true

require 'influxdb-client'
require 'influxdb-client-apis'
require 'pry'

module IpStats
  QUERY_LIST = [
    { name: 'min_latency', function: 'min()' },
    { name: 'max_latency', function: 'max()' },
    { name: 'mean_latency', function: 'mean()' },
    { name: 'stddev_latency', function: 'stddev()' }
  ].freeze

  class << IpStats
    def stats(influx, ip, start_date, end_date)
      @ip = ip
      @start_date = start_date
      @end_date = end_date

      query_api = influx.create_query_api

      result = query_api.query(query: query)
      return result.to_json if result.empty?

      result[0].records.first.values.to_json
    end

    private

    def query
      query_list = QUERY_LIST.map { |sub_query| build_query(sub_query[:function], sub_query[:name]) }
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

    def build_query(function, column_name)
      sub_query = %(#{base_query} |> #{function} |> set(key: "_field", value: "#{column_name}"))

      { column: column_name, sub_query: sub_query }
    end
  end
end
