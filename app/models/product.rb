class Product < ApplicationRecord
  acts_as_paranoid

  belongs_to :category
  has_many :orders, dependent: :destroy
  has_one_attached :image, dependent: :destroy do |photo|
    photo.variant :preview, resize_to_fill: [200, 150], preprocessed: true
  end

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :filter_by_product, ->(product) { where(name: product) }
end
