class Category < ApplicationRecord
  acts_as_paranoid

  has_many :products, dependent: nil

  validates :name, presence: true, uniqueness: true
end
