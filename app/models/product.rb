class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :category
  has_many :orders, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
