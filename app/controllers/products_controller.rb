class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[edit update]
  before_action :set_product_with_deleted, only: %i[show restore destroy really_destroy]

  def index
    @products = Product.includes(:category).page(params[:page])
  end

  def archive
    @products = Product.includes(:category).only_deleted.page(params[:page])
    respond_to do |format|
      format.html { render 'index' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('products',
                                                  template: 'products/index', locals: { products: @products })
      end
    end
  end

  def show; end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        flash.now[:success] = "Product was successfully created."
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
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

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(:modal),
            turbo_stream.prepend('flash', partial: 'shared/flash'),
            turbo_stream.replace('products', template: 'products/show', locals: { product: @product })
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
    end
  end

  def restore
    respond_to do |format|
      if @product.restore
        format.html { redirect_to product_path(@product), notice: "Product was successfully restored." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('products',
                                                    template: 'products/show', locals: { product: @product })
        end
      else
        format.html { render :show }
      end
    end
  end

  def really_destroy
    respond_to do |format|
      if @product.really_destroy!
        format.html { redirect_to products_url, notice: "Product was successfully deleted." }
      else
        format.html { render :show }
      end
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_product_with_deleted
    @product = Product.with_deleted.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :quantity, :category_id, :image)
  end
end
