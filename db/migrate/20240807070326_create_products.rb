class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false, default: ''
      t.decimal :price, null: false, default: 0.0
      t.integer :quantity, null: false, default: 0
      t.datetime :deleted_at
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :products, :name, unique: true
  end
end