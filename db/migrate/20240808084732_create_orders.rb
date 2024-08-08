class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :state, default: 0, null: false
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :cancelable_until
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :orders, :deleted_at
  end
end
