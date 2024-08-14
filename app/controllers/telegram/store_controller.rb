module Telegram
  class StoreController < ApplicationController
    layout 'application_telegram'

    has_scope :filter_by_category, as: :category_id

    def index
      @products_by_category = Product.with_attached_image.includes(:category).all.group_by(&:category)
    end
  end
end
