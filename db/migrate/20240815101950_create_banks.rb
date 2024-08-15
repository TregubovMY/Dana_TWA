class CreateBanks < ActiveRecord::Migration[7.1]
  def change
    create_table :banks do |t|
      t.string :name, null: false, default: '', index: { unique: true }

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :banks, :deleted_at
  end
end
