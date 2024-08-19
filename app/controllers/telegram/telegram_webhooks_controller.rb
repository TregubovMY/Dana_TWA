module Telegram
  class TelegramWebhooksController < Telegram::Bot::UpdatesController
    include Telegram::Bot::UpdatesController::MessageContext

    before_action :find_user

    def start!(*)
      TelegramService.hide_web_app_button(chat_id: chat['id'])

      if @user&.approve
        TelegramService.show_web_app_button(chat_id: chat['id'])
        respond_with :message, text: t('telegram.messages.open_menu', username: @user.username),
                               reply_markup: {
                                 inline_keyboard: [
                                   [{ text: 'Открыть сайт', web_app: { url: 'https://panther-kind-usually.ngrok-free.app' } }]
                                 ]
                               }
      else
        telegram_username = from['username'] || from['first_name']
        User.create_user_telegram(telegram_username:, telegram_chat_id: from['id']) unless @user
        TelegramService.send_message_managers(text: t('telegram.messages.new_user_connected',
                                                      username: telegram_username))
        respond_with :message, text: t('telegram.messages.greeting', username: from['username'])
      end
    end

    def approve_payment!(*)
      TelegramService.send_message_managers(text: t('telegram.messages.user_confirmed_payment',
                                                    username: @user.username))
      respond_with :message, text: t('telegram.messages.payment_confirmed')
    end

    private

    def find_user
      @user = User.find_by(telegram_chat_id: from['id'])
    end
  end
end
