class Order < ApplicationRecord
  acts_as_paranoid

  enum :state, { created: 0, completed: 1, cancelled: 2 }, _prefix: true

  belongs_to :product, -> { with_deleted }, inverse_of: :orders
  belongs_to :user, -> { with_deleted }, inverse_of: :orders
  has_one :payment, dependent: :destroy
end
