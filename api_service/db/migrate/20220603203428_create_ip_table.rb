# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :ips do
      primary_key :id
      column :ip, String, null: false
      column :enable, TrueClass, default: true

      index :ip
    end
  end
end