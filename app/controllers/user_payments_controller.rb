class UserPaymentsController < UsersController
  before_action :set_user, except: [:pay_order]

  has_scope :filter_by_user, as: :user
  has_scope :filter_by_date, using: %i[date_start date_end], as: :date

  def payment; end

  def pay_all_orders
    params.merge! DateFilterService.prepare_date_filter_params(params[:start_date_between])

    @orders = apply_scopes(Order).filter_by_state(:created).where(user_id: params[:id]).includes(:payment)
    PaymentsService.pay_all_orders(@orders)
  end

  def deposit_money
    ActiveRecord::Base.transaction do
      user_replenishment = params[:user][:deposit].to_f

      @user.update!(deposit: @user.deposit + user_replenishment)
      PaymentsService.process_orders_sequentially_at(@user)
    end
  end

  def pay_order
    @order = Order.includes(:payment).find(params[:id])
    if PaymentsService.pay_all_orders([@order])
      redirect_to orders_path
    else
      # flash.now[:error] = t('.error')
      render order_path(@order)
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
