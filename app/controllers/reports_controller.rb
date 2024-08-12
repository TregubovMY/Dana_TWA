class ReportsController < ApplicationController
  has_scope :filter_by_user, as: :user
  has_scope :filter_by_date, using: [:date_start, :date_end], as: :date
  has_scope :filter_by_state, as: :state
  has_scope :filter_by_product, as: :product

  def index
    params.merge! DateFilterService.prepare_date_filter_params(params[:start_date_between])
    Rails.logger.info params
    @reports = apply_scopes(Order).includes(:user, :payment, :product).page(params[:page])
  end

  def users_reports
    @reports = apply_scopes(User).approved.includes(:orders, :payments).page(params[:page])
  end
end
