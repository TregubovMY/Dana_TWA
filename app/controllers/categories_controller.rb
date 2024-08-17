class CategoriesController < ApplicationController
  before_action :set_category, only: %i[destroy]

  def index
    @categories = Category.all.page(params[:page]).per(10)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('products',
                                                  template: 'categories/index', locals: { categories: @categories })
      end
    end
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_url, notice: t('.success') }
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
      if @category.update(category_params)
        format.html { redirect_to category_url(@category), notice: t('.success') }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_url, notice: t('.success') }
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end