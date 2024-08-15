class MailingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @mailings = Mailing.all
  end

  def settings
    @setting = MailingSetting.first
  end

  def update_settings
    Rails.logger.info "Update mailing settings: #{mailing_params}"

    redirect_to :settings
  end

  private

  def mailing_params
    params.require(:mailing).permit(:phone, :bank_id, :image, :active)
  end
end
