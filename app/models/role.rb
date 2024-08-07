class Role < ApplicationRecord
  has_one :users_role, dependent: :destroy
end
