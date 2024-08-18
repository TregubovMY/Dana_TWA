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

  def self.your_orders(user:, orders:) # TODO refactor и не работает подсчет правильно, оптимизировать
    orders_list = ''
    current_month_orders = 0
    debt = ReportsService.summarize_orders_price([Order.find_by(state: :created, user_id: user.id)])
    orders.each do |order|
      orders_list += "#{order.product.name} #{I18n.l(order.created_at, format: :medium)},
                      #{I18n.t('activerecord.attributes.payment.amount')}:
                      #{order.payment.amount} ₽ (#{order.payment.state})\n"
      current_month_orders += order.payment.amount if order.state == :created
    end

    Telegram.bot.send_message(chat_id: user.telegram_chat_id, text: I18n.t('telegram.messages.your_orders',
                                                                           orders_list:,
                                                                           current_month_orders:,
                                                                           debt:,
                                                                           deposit: user.deposit))
  end

  def self.send_payment_request # TODO refactor и вероятно тоже не работает
    settings = MailingSetting.first
    User.approved.each do |user|
      total_debt = ReportsService.summarize_price_orders_users([user])
      debt = ReportsService.summarize_price_orders_users_last_month([user])
      Telegram.bot.send_message(chat_id: user.telegram_chat_id,
                                text: I18n.t('telegram.messages.payment_request', debt:,
                                                                                  total_debt:,
                                                                                  phone_number: settings.phone_number,
                                                                                  bank_name: settings.bank))
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
