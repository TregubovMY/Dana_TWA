class UsersController < ApplicationController
  load_and_authorize_resource param_method: :user_params
  before_action :set_user, only: %i[edit update approve]
  before_action :find_deleted_user, only: %i[show restore destroy really_destroy]

  def index
    @users = User.filter_by_username(params[:search_query]).approved.includes(:role).page(params[:page]).per(10)
  end

  def requests
    @users = User.unapproved.page(params[:page])
  end

  def archive
    @users = User.only_deleted.includes(:role).page(params[:page])

    render 'index'
  end

  def show; end

  def edit; end

  def update
    ActiveRecord::Base.transaction do
      update_user_role
      update_user_attributes
    end

    redirect_to user_url(@user), notice: t('.success_updated')

  rescue
    render :edit, status: :unprocessable_entity
  end

  def destroy
    if @user.destroy
      TelegramService.after_rejection(chat_id: @user.telegram_chat_id)
      redirect_to users_path, notice: t('.success')
    else
      render :show
    end
  end

  def restore
    if @user.restore
      redirect_to user_url(@user), notice: t('.success')
    else
      render :show, status: :unprocessable_entity
    end
  end

  def really_destroy
    if @user.really_destroy!
      redirect_to archive_users_path, notice: t('.success')
    else
      render archive_users_path, status: :unprocessable_entity
    end
  end

  def approve
    if @user.approve!
      TelegramService.after_approve(chat_id: @user.telegram_chat_id)
      redirect_to requests_users_path, notice: t('.success')
    else
      render :index, status: :unprocessable_entity
    end
  end

  def approve_all
    @users = User.unapproved
    if @users.update_all(approve: true)
      @users.each { |user| TelegramService.after_approve(chat_id: user.telegram_chat_id) }
      redirect_to requests_users_path, notice: t('.success')
    else
      render requests_users_path, notice: t('.no_users')
    end
  end

  def delete_all
    @users = User.unapproved
    if @users.unapproved.destroy_all
      @users.each do |user|
        user.approve = false
        TelegramService.after_rejection(chat_id: user.telegram_chat_id)
        TelegramService.hide_web_app_button(chat_id: user.telegram_chat_id)
      end
      redirect_to requests_users_path, notice: t('.success')
    else
      redirect_to requests_users_path, notice: t('.no_users')
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def find_deleted_user
    @user = User.with_deleted.find(params[:id])
  end

  def user_params
    params.require(:user).permit(current_ability.permitted_attributes(:update, @user))
  end

  def update_user_role
    @user.role = Role.find(user_params[:role_id])
  end

  def update_user_attributes
    attrs = user_params.except(:role_id)

    if attrs[:password].present? && !@user.admin_or_manager?
      @user.errors.add(:password, :not_authorized)
      return false
    end

    if attrs[:password].blank?
      @user.update_without_password(attrs)
    else
      @user.update(attrs)
    end
  end
end
