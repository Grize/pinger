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
      return result if result.empty?

      result[0].records.first.values
    end

    private

    def query
      query_list = QUERY_LIST.map { |sub_query| build_query(sub_query[:function], sub_query[:name]) }
      sub_queries = query_list.map { |sub_query| sub_query[:sub_query] }.join(',')
      columns = query_list.map { |sub_query| sub_query[:column] }.concat(%w[host failed_count total_count])

      %(union(tables: [#{sub_queries}, #{failed_query}, #{total_query}])
        |> pivot(rowKey: ["_start"], columnKey: ["_field"], valueColumn: "_value")
        |> keep(columns: #{columns})
      )
    end

    def base_query
      %(
        from(bucket:"servers")
        |> range(start: #{@start_date}, stop: #{@end_date})
        |> filter(fn: (r) => r["_measurement"] == "ip" and r["host"] == "#{@ip}" and r["failed"] == "false")
        |> group(columns: ["host"])
      )
    end

    def failed_query
      %(
        from(bucket:"servers")
        |> range(start: #{@start_date}, stop: #{@end_date})
        |> filter(fn: (r) => r["_measurement"] == "ip" and r["host"] == "#{@ip}")
        |> group(columns: ["host"])
        |> map(fn: (r) => ({ r with _value: if r["failed"] == "true" then 1 else 0 }))
        |> sum()
        |> toFloat()
        |> set(key: "_field", value: "failed_count")
      )
    end

    def total_query
      %(
        from(bucket:"servers")
        |> range(start: #{@start_date}, stop: #{@end_date})
        |> filter(fn: (r) => r["_measurement"] == "ip" and r["host"] == "#{@ip}")
        |> group(columns: ["host"])
        |> count()
        |> toFloat()
        |> set(key: "_field", value: "total_count")
      )
    end

    def build_query(function, column_name)
      sub_query = %(#{base_query} |> #{function} |> set(key: "_field", value: "#{column_name}"))

      { column: column_name, sub_query: sub_query }
    end
  end
end
