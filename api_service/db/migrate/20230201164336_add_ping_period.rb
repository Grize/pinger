# frozen_string_literal: true

ROM::SQL.migration do
  change do
    add_column :ips, :ping_period, :integer, null: false, default: 60
  end
end
