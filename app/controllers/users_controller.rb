class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[edit update approve]
  before_action :find_deleted_user, only: %i[show restore destroy really_destroy]

  def index
    @users = User.filter_by_name(params[:search_query]).approved.includes(:role).page(params[:page])
  end

  def requests
    @users = User.unapproved.page(params[:page])
  end

  def archive
    @users = User.only_deleted.page(params[:page])

    respond_to do |format|
      format.html { render 'index' }
    end
  end

  def show; end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      ActiveRecord::Base.transaction do
        update_user_role
        if update_user_attributes
          format.html { redirect_to user_url(@user), notice: "User was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.destroy
        format.html { redirect_to user_url(@user), notice: "User was successfully destroyed." }
      else
        format.html { render :show }
      end
    end
  end

  def restore
    respond_to do |format|
      if @user.restore
        format.html { redirect_to user_url(@user), notice: "User was successfully restored." }
      else
        format.html { render :show }
      end
    end
  end

  def really_destroy
    respond_to do |format|
      if @user.really_destroy!
        format.html { redirect_to users_url, notice: "User was successfully deleted." }
      else
        format.html { render :show }
      end
    end
  end

  def approve
    respond_to do |format|
      if @user.approve!
        format.html { redirect_to approve_user_url, notice: "User was successfully approve." }
      else
        format.html { render :index }
      end
    end
  end

  def approve_all
    if User.unapproved.update_all(approve: true)
      redirect_to requests_users_path, notice: "All users were successfully approved."
    else
      redirect_to requests_users_path, notice: "There are no unapproved users."
    end
  end

  def delete_all
    if User.unapproved.destroy_all
      redirect_to requests_users_path, notice: "All users were successfully deleted."
    else
      redirect_to requests_users_path, notice: "There are no unapproved users to delete."
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
