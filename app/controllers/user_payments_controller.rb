class UserPaymentsController < ApplicationController
  authorize_resource class: false
  before_action :set_user, except: [:pay_order]

  has_scope :filter_by_username, as: :user
  has_scope :filter_by_date, using: %i[date_start date_end], as: :date

  def payment; end

  def pay_all_orders
    params.merge! DateFilterService.prepare_date_filter_params(params[:start_date_between])

    @orders = apply_scopes(Order).filter_by_state(:created).where(user_id: params[:id]).includes(:payment)
    if PaymentsService.pay_all_orders(@orders)
      redirect_to reports_path, notice: 'Все заказы оплачены'
    else
      redirect_to reports_path, notice: 'Произошла ошибка при оплате'
    end
  end

  def deposit_money
    user_replenishment = params[:user][:deposit].to_f

    ActiveRecord::Base.transaction do
      @user.update!(deposit: @user.deposit + user_replenishment)
      PaymentsService.process_orders_sequentially_at(@user)
    end

    redirect_to users_reports_path, notice: 'Деньги успешно зачислены'
  rescue StandardError => e
    redirect_to users_reports_path, alert: "Ошибка при зачислении денег: #{e.message}"
  end

  def pay_order
    @order = Order.includes(:payment).find(params[:id])
    if PaymentsService.pay_all_orders([@order])
      redirect_to product_path(@order.product), notice: 'Заказ оплачен'
    else
      render product_path(@order.product), notice: 'Произошла ошибка при оплате'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
