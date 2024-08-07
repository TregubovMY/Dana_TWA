class CreateUsersRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :users_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users_roles, :deleted_at
  end
end
