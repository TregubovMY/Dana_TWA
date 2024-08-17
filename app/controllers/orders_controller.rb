class OrdersController < ApplicationController
  load_and_authorize_resource param_method: :order_params

  def index
    @orders = Order.without_deleted.includes(:product, :user).page(params[:page]).per(12)
  end

  def show
    @order = Order.with_deleted.find(params[:id])
  end

  def archive
    @orders = Order.only_deleted.includes(:product, :user).page(params[:page]).per(14)

    respond_to do |format|
      format.html { render 'index' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('orders',
                                                  template: 'orders/index', locals: { orders: @orders })
      end
    end
  end

  def users
    @orders = current_user.orders.includes(:product, :payment)

    TelegramService.your_orders(user: current_user, orders: @orders)
    redirect_to store_index_path, notice: "Заказы отправлены сообщением в чат"
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        flash.now[:success] = t('.success')
        format.html { redirect_to order_url(@order), notice: t('.success') }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(:modal),
            turbo_stream.prepend('flash', partial: 'shared/flash')
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def create_for_product
    product = Product.find(params[:product_id])
    order = current_user.orders.create(product:)

    if order.save
      TelegramService.after_create_order(user: current_user, product: product)
      redirect_to store_index_path, notice: 'Заказ успешно создан'
    else
      redirect_to store_index_path, alert: 'Ошибка при создании заказа'
    end
  end

  def destroy
    Rails.logger.info "Order: #{params}"
    @order = Order.find(params[:id])
    if @order.destroy
      redirect_to orders_path, notice: t('.success')
    else
      flash.now[:error] = t('.error')
      render :show
    end
  end

  def delete_last
    last_order = current_user.orders.filter_by_state(:created).last # TODO: открытые нужно выбрать

    Rails.logger.info "Last order: #{last_order.inspect}, time: #{Time.now}, state: #{last_order.cancelled?}"

    if last_order.cancelled?
      last_order.transaction do
        last_order.update!(state: :cancelled)
        last_order.payment.update!(state: :failed)
      end
      Rails.logger.info "TelegramService.after_delete_order: #{current_user.inspect}"
      TelegramService.after_delete_order(user: current_user)
      redirect_to store_index_path, notice: 'Последний заказ отменен'
    else
      TelegramService.deleted_impossible(user: current_user)
      redirect_to store_index_path, alert: 'Ошибка при отмене заказа'
    end
  end

  private

  def order_params
    params.require(:order).permit(:state, :product_id, :user_id)
  end
end
