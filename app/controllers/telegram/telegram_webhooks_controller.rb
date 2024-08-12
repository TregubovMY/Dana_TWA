module Telegram
  class TelegramWebhooksController < Telegram::Bot::UpdatesController
    include Telegram::Bot::UpdatesController::MessageContext

    before_action :set_user, only: %i[start! check_approve!]

    def start!(*)
      hide_web_app_button(chat['id'])

      if @user&.approve
        show_web_app_button(chat['id'])
        respond_with :message, text: I18n.t('telegram.messages.already_approved')
      else
        User.create_user_telegram(telegram_username: from['username'], telegram_chat_id: from['id']) unless @user
        respond_with :message, text: I18n.t('telegram.messages.greeting', username: from['username'])
      end
    end

    def check_approve!
      if @user&.approve
        show_web_app_button(chat['id'])
        respond_with :message, text: I18n.t('telegram.messages.approved')
      else
        respond_with :message, text: I18n.t('telegram.messages.not_approved')
      end
    end

    private

    def show_web_app_button(chat_id)
      show_menu = { chat_id:, type: 'web_app', text: 'Menu',
                    web_app: { url: 'https://panther-kind-usually.ngrok-free.app' } }.to_json
      Telegram.bot.set_chat_menu_button(menu_button: show_menu)
    end

    def hide_web_app_button(chat_id)
      Telegram.bot.set_chat_menu_button(
        menu_button: { chat_id:, type: 'default' }.to_json
      )
    end

    def set_user
      @user = User.find_by(telegram_chat_id: from['id'])
    end
  end
end
