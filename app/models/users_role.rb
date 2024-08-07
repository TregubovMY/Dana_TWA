class UsersRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  acts_as_paranoid
end
