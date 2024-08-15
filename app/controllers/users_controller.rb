class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[edit update approve]
  before_action :find_deleted_user, only: %i[show restore destroy really_destroy]

  def index
    @users = User.filter_by_name(params[:search_query]).approved.includes(:role).page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('users',
                                                  template: 'users/users', locals: { users: @users })
      end
    end
  end

  def requests
    @users = User.unapproved.page(params[:page])
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('users',
                                                  template: 'users/requests', locals: { users: @users })
      end
    end
  end

  def archive
    @users = User.only_deleted.includes(:role).page(params[:page])

    respond_to do |format|
      format.html { render 'index' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('users',
                                                  template: 'users/users', locals: { users: @users })
      end
    end
  end

  def show; end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('users', template: 'users/edit', locals: { user: @user })
      end
    end
  end

  def update
    respond_to do |format|
      ActiveRecord::Base.transaction do
        update_user_role
        if update_user_attributes
          format.html { redirect_to user_url(@user), notice: t('.success_updated') }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace('users',
                                                      template: 'users/show', locals: { user: @user })
          end
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.destroy
        TelegramService.after_rejection(chat_id: @user.telegram_chat_id)
        format.html { redirect_to user_url(@user), notice: t('.success') }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('users',
                                                    template: 'users/show', locals: { user: @user })
        end
      else
        format.html { render :show }
      end
    end
  end

  def restore
    respond_to do |format|
      if @user.restore
        format.html { redirect_to user_url(@user), notice: t('.success') }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('users',
                                                    template: 'users/show', locals: { user: @user })
        end
      else
        format.html { render :show }
      end
    end
  end

  def really_destroy
    respond_to do |format|
      if @user.really_destroy!
        format.html { redirect_to archive_users_path, notice: t('.success') }
      else
        format.html { render archive_users_path }
      end
    end
  end

  def approve
    respond_to do |format|
      if @user.approve!
        TelegramService.after_approve(chat_id: @user.telegram_chat_id)
        format.html { redirect_to requests_users_path, notice: t('.success') }
      else
        format.html { render :index }
      end
    end
  end

  def approve_all
    @users = User.approved
    if @users.update_all(approve: true)
      @users.each { |user| TelegramService.after_approve(chat_id: user.telegram_chat_id) }
      redirect_to requests_users_path, notice: t('.success')
    else
      redirect_to requests_users_path, notice: t('.no_users')
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
    params.require(:user).permit(:username, :approve, :deposit, :password, :password_confirmation, :role_id)
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
