class Category < ApplicationRecord
  acts_as_paranoid

  has_many :products, dependent: nil

  validates :name, presence: true, uniqueness: true

  before_destroy :reassign_products_to_default_category

  private

  def reassign_products_to_default_category
    default_category = Category.where(name: 'other').first_or_create!

    products.update_all(category_id: default_category.id)
  end
end
