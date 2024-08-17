class MailingsController < ApplicationController
  load_and_authorize_resource param_method: :mailing_params

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
