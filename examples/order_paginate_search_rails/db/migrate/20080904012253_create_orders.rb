class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :user_id
      t.integer :total
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
