# frozen_string_literal: true

ROM::SQL.migration do
  change do
    # TODO => change primary key to ip
    create_table :ips do
      primary_key :ip, String
      column :enable, TrueClass, default: true

      index :ip
    end
  end
end
