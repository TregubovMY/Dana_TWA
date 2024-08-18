class ReportsController < ApplicationController
  authorize_resource class: false
  before_action :merge_date_filter_params

  has_scope :filter_by_username, as: :user
  has_scope :filter_by_date, using: %i[date_start date_end], as: :date
  has_scope :filter_by_state, as: :state
  has_scope :filter_by_product, as: :product

  def index
    @orders = apply_scopes(Order).includes(:user, :payment, :product).page(params[:page]).per(8)
    @summarize_orders_price = ReportsService.summarize_orders_price(@orders)
  end

  def users_reports
    @users = apply_scopes(User).approved.includes(:orders, :payments).page(params[:page]).per(8)
    @price_orders = ReportsService.summarize_price_orders_users(@users)
    @count_orders = ReportsService.count_orders(@users)
  end

  private

  def merge_date_filter_params
    params.merge! DateFilterService.prepare_date_filter_params(params[:start_date_between])
  end
end
