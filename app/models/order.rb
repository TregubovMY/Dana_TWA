class Order < ApplicationRecord
  acts_as_paranoid

  belongs_to :product, -> { with_deleted }, inverse_of: :orders
  belongs_to :user, -> { with_deleted }, inverse_of: :orders
  has_one :payment, dependent: :destroy
end
