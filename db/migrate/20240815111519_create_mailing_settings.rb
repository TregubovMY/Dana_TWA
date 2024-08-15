class CreateMailingSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :mailing_settings do |t|
      t.string :phone, null: false
      t.references :bank, null: false, foreign_key: true
      t.boolean :active, default: false

      t.datetime :deleted_at
    end

    add_index :mailing_settings, :deleted_at
  end
end
