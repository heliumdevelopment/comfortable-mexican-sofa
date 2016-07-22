class ExtendUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_type, :string, default: 'manager'
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
