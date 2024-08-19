class TelegramService
  def self.after_approve(chat_id:)
    show_web_app_button(chat_id:)
    Telegram.bot.send_message(chat_id:, text: I18n.t('telegram.messages.approved'))
  end

  def self.after_rejection(chat_id:)
    hide_web_app_button(chat_id:)
    Telegram.bot.send_message(chat_id:, text: I18n.t('telegram.messages.not_approved'))
  end

  def self.after_create_order(user:, product:)
    total_debt = ReportsService.summarize_price_orders_users([user])
    Telegram.bot.send_message(chat_id: user.telegram_chat_id,
                              text: I18n.t('telegram.messages.order_created', product_name: product.name,
                                                                              price: product.price,
                                                                              total_debt:))
  end

  def self.after_delete_order(user:)
    Telegram.bot.send_message(chat_id: user.telegram_chat_id, text: I18n.t('telegram.messages.order_deleted'))
  end

  def self.deleted_impossible(user:)
    Telegram.bot.send_message(chat_id: user.telegram_chat_id, text: I18n.t('telegram.messages.deleted_impossible'))
  end

  # TODO: Еще сильнее упростить запросы
  def self.your_orders(user:)
    orders_price_this_month, count_orders_this_month = ReportsService.summarize_price_and_count_orders_users_this_month(user)
    orders_price_last_month, count_orders_last_month = ReportsService.summarize_price_and_count_orders_users_last_month(user)
    total_debt = ReportsService.summarize_price_created_orders_for(user)
    orders = user.orders.includes(:product).where(state: :created).order(created_at: :desc)
                 .map do |order|
                   "#{order.product.name} #{I18n.l(order.created_at, format: :long)} цена
                    #{order.product.price} ₽ (#{I18n.t("activerecord.attributes.order.created")})"
                 end.join("\n")
    Telegram.bot.send_message(chat_id: user.telegram_chat_id,
                              text: I18n.t('telegram.messages.your_orders',
                                           orders:,
                                           count_orders_this_month:,
                                           count_orders_this_month_text: I18n.t('order', count: count_orders_this_month),
                                           orders_price_this_month:,
                                           count_orders_last_month:,
                                           count_orders_last_month_text: I18n.t('order', count: count_orders_last_month),
                                           orders_price_last_month:,
                                           total_debt:,
                                           deposit: user.deposit))
  end

  # TODO: Переделать в пару запросов через агрегатные функции и нормальный sql запрос
  def self.send_payment_request
    settings = MailingSetting.find(MailingSetting.DEFAULT_MAILING_SETTING_ID)
    User.approved.each do |user|
      total_debt = ReportsService.summarize_price_created_orders_for(user)
      Telegram.bot.send_message(chat_id: user.telegram_chat_id,
                                text: I18n.t('telegram.messages.payment_request',
                                             total_debt:,
                                             phone_number: settings.phone,
                                             bank_name: settings.bank.name))
    end
  end

  def self.send_message_managers(text:)
    role = Role.find_by!(name: 'manager')
    managers = User.joins(:role).where(roles: { id: role.id })

    managers.find_each do |manager|
      Telegram.bot.send_message(chat_id: manager.telegram_chat_id, text:)
    end
  end

  def self.show_web_app_button(chat_id:)
    show_menu = { chat_id:, type: 'web_app', text: 'Menu',
                  web_app: { url: 'https://panther-kind-usually.ngrok-free.app' } }.to_json
    Telegram.bot.set_chat_menu_button(menu_button: show_menu)
  end

  def self.hide_web_app_button(chat_id:)
    Telegram.bot.set_chat_menu_button(
      menu_button: { chat_id:, type: 'default' }.to_json
    )
  end
end
