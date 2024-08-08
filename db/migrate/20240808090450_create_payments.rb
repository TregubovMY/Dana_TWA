class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.integer :state, default: 0, null: false
      t.decimal :amount, null: false
      t.references :order, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :payments, :deleted_at
  end
end
