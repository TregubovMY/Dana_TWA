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

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        flash.now[:success] = "Order was successfully created."
        format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
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

  def destroy
    @order = Order.find(params[:id]).includes(:product, :user)

    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
    end
  end

  private

  def order_params
    params.require(:order).permit(:state, :product_id, :user_id)
  end
end
