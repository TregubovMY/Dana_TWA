module Telegram
  class StoreController < ApplicationController
    layout 'application_telegram'

    def index
      @telegram_chat_id = session[:telegram_chat_id]

      if @telegram_chat_id
        # Пользователь авторизован, можно выполнить дополнительные действия
        Rails.logger.info "Пользователь авторизован: #{@telegram_chat_id}"
      else
        # Пользователь не авторизован, можно перенаправить или выполнить другие действия
        Rails.logger.warn "Пользователь не авторизован!"
      end
    end
  end
end
