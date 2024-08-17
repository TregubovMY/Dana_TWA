module Telegram
  class StoreController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :custom_authenticate_user!
    layout 'application_telegram'

    has_scope :filter_by_category, as: :category_id

    def index
      @products_by_category = Product.with_attached_image.includes(:category).all.group_by(&:category)
    end

    private

    def custom_authenticate_user!
      redirect_to root_path if current_user.blank?
    end
  end
end
