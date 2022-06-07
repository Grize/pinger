# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :ips do
      column :ip, String, null: false
      column :enable, TrueClass, default: true

      primary_key [:ip]
    end
  end
end
