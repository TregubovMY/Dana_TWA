class ReportsController < ApplicationController
  authorize_resource class: false
  before_action :merge_date_filter_params

  has_scope :filter_by_username, as: :user
  has_scope :filter_by_date, using: %i[date_start date_end], as: :date
  has_scope :filter_by_state, as: :state
  has_scope :filter_by_product, as: :product

  def index
    @orders = apply_scopes(Order).includes(:user, :payment, :product).page(params[:page]).per(8)

    @price_orders = @orders.sum { |el| el.payment.amount }
    @count_orders = @orders.count
  end

  def users_reports
    @users = apply_scopes(User).approved
                               .joins(orders: :payment)
                               .group('users.id')
                               .select('users.*, SUM(payments.amount) AS total_price, COUNT(orders.id) AS total_count')
                               .order(id: :desc)
                               .page(params[:page]).per(8)

    @price_orders = @users.sum(&:total_price)
    @count_orders = @users.sum(&:total_count)
  end

  private

  def merge_date_filter_params
    params.merge! DateFilterService.prepare_date_filter_params(params[:start_date_between])
  end
end
