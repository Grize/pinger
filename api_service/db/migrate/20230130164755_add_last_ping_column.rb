# frozen_string_literal: true

ROM::SQL.migration do
  change do
    add_column :ips, :last_ping, :timestamp, null: false
  end
end
