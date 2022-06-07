# frozen_string_literal: true

class StatsSerializer
  attr_reader :raw_stats

  def initialize(raw_stats)
    @raw_stats = raw_stats
  end

  def as_json
    ## For addresses without data we return nil
    ## TODO => maybe we should return something else
    return raw_stats if raw_stats.empty?

    {
      min_latency: format_field('min_latency'),
      max_latency: format_field('max_latency'),
      mean_latency: format_field('mean_latency'),
      stddev_latency: format_field('stddev_latency'),
      percent_failed: (raw_stats['failed_count'] / raw_stats['total_count'] * 100).round(2)
    }
  end

  private

  def format_field(key)
    raw_stats[key] ? raw_stats[key].round(2) : nil
  end
end
