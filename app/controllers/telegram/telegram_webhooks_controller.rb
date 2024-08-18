module Telegram
  class TelegramWebhooksController < Telegram::Bot::UpdatesController
    include Telegram::Bot::UpdatesController::MessageContext

    def start!(*)
      TelegramService.hide_web_app_button(chat_id: chat['id'])
      @user = @user = User.find_by(telegram_chat_id: from['id'])

      if @user&.approve
        TelegramService.show_web_app_button(chat_id: chat['id'])
        respond_with :message, text: t('telegram.messages.open_menu')
      else
        telegram_username = from['username'] || from['first_name']
        User.create_user_telegram(telegram_username:, telegram_chat_id: from['id']) unless @user
        respond_with :message, text: t('telegram.messages.greeting', username: from['username'])
      end
    end
  end
end
