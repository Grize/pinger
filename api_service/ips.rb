# frozen_string_literal: true

require 'rom'

module Relations
  class Ips < ROM::Relation[:sql]
    schema(:ips, infer: true)
  end
end
