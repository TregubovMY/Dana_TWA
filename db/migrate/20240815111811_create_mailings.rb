class CreateMailings < ActiveRecord::Migration[7.1]
  def change
    create_table :mailings do |t|
      t.references :mailing_setting, null: false, foreign_key: true
      t.integer :kind

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :mailings, :deleted_at
  end
end
