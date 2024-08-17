module Telegram
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[new create]
    layout 'application_telegram'

    def new; end

    def create
      user_id = TelegramAuthenticationService.authenticate_user(params[:init_data])

      if user_id
        sign_in(User.find_by(telegram_chat_id: user_id))
        respond_to do |format|
          format.html { redirect_to store_index_path, notice: "Вы успешно вошли через Telegram!" }
          format.json { render json: { redirect_url: store_index_url }, status: :ok }
        end
      else
        respond_to do |format|
          format.html { render file: Rails.public_path.join('403.html'), status: :forbidden }
          format.json { render json: { error: 'Authentication failed' }, status: :forbidden }
        end
      end
    end
  end
end
