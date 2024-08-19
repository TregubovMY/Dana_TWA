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
      redirect_to new_telegram_session_path unless current_user

      render file: Rails.public_path.join('403.html'), status: :forbidden if current_user&.approve == false
    end
  end
end
