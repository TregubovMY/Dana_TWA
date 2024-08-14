class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = Order.includes(:product, :user).page(params[:page])
  end

  def show
    @order = Order.with_deleted.find(params[:id])
  end

  def archive
    @orders = Order.only_deleted.includes(:product, :user).page(params[:page])

    respond_to do |format|
      format.html { render 'index' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('orders',
                                                  template: 'orders/index', locals: { orders: @orders })
      end
    end
  end

  def users
    @orders = current_user.orders.includes(:product)

    # TODO: написать ответ в тг
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
      redirect_to store_index_path, notice: 'Заказ успешно создан'
    else
      redirect_to store_index_path, alert: 'Ошибка при создании заказа'
    end
  end

  def destroy
    @order = Order.find(params[:id]).includes(:product, :user)

    respond_to do |format|
      format.html { redirect_to orders_url, notice: t('.success') }
    end
  end

  def delete_last
    last_order = current_user.orders.last

    Rails.logger.info "Last order: #{last_order.inspect}, time: #{Time.now}, state: #{last_order.cancelled?}"

    if last_order.cancelled?
      last_order.transaction do
        last_order.update!(state: :cancelled)
        last_order.payment.update!(state: :failed)
      end
      redirect_to store_index_path, notice: 'Последний заказ отменен'
    else
      redirect_to store_index_path, alert: 'Ошибка при отмене заказа'
    end
  end

  private

  def order_params
    params.require(:order).permit(:state, :product_id, :user_id)
  end
end
