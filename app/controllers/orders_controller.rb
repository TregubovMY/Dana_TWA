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
    respond_with_template('orders/index')
  end

  def users
    TelegramService.your_orders(user: current_user)
    redirect_to store_index_path, notice: 'Заказы отправлены сообщением в чат'
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    process_order_transaction(@order, -1) do
      flash.now[:success] = t('.success')
      respond_with_success
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_with_error(:new, e)
  end

  def create_for_product
    product = Product.find(params[:product_id])

    if product.quantity <= 0
      redirect_to store_index_path, alert: 'Товара нет в наличии'
      return
    end

    order = current_user.orders.build(product: product)
    process_order_transaction(order, -1) do
      TelegramService.after_create_order(user: current_user, product: product)
      redirect_to store_index_path, notice: 'Заказ успешно создан'
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to store_index_path, alert: "Ошибка при создании заказа: #{e.message}"
  end

  def destroy
    @order = Order.find(params[:id])
    if @order.destroy
      redirect_to orders_path, notice: t('.success')
    else
      flash.now[:error] = t('.error')
      render :show
    end
  end

  def delete_last
    last_order = current_user.orders.filter_by_state(:created).last

    if last_order&.cancelled?
      process_order_transaction(last_order, 1) do
        last_order.update!(state: :cancelled)
        last_order.payment.update!(state: :failed)
        TelegramService.after_delete_order(user: current_user)
      end
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

  def update_inventory(product, quantity_change)
    product.with_lock do
      new_quantity = product.quantity + quantity_change
      raise ActiveRecord::RecordInvalid, product if new_quantity.negative?

      product.update!(quantity: new_quantity)
    end
  end

  def process_order_transaction(order, quantity_change)
    ActiveRecord::Base.transaction do
      update_inventory(order.product, quantity_change)
      order.save!
      yield if block_given?
    end
  end

  def respond_with_template(template)
    respond_to do |format|
      format.html { render template }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('orders', template:, locals: { orders: @orders })
      end
    end
  end

  def respond_with_success
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(:modal),
          turbo_stream.prepend('flash', partial: 'shared/flash')
        ]
      end
    end
  end

  def respond_with_error(template, error)
    flash.now[:error] = error.message
    respond_to do |format|
      format.html { render template, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(:modal),
          turbo_stream.prepend('flash', partial: 'shared/flash')
        ]
      end
    end
  end
end
