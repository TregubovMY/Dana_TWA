class UsersRole < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, -> { with_deleted }, inverse_of: :roles
  belongs_to :role, -> { with_deleted }, inverse_of: :users
end
