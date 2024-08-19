require_relative 'seeds/seeds_helper'

include SeedsHelpers

# Роли
user_role = create_role('user')
admin_role = create_role('admin')
manager_role = create_role('manager')

# Категории
other_category = create_category('other')

# Банк
bank = create_bank('Sberbank')

# Настройки рассылки
create_mailing_setting(bank)

if Rails.env.development?
  # Администратор
  admin = create_user(username: 'admin', password: '123456', role: admin_role,
                      telegram_chat_id: 'admin_id', telegram_username: 'admin')

  # Категории и продукты
  category1 = create_category('Фрукты')
  category2 = create_category('Сладкое')

  product1 = create_product('Яблоки Гренни', 100, 10, category1)
  product2 = create_product('Бананы', 100, 10, category1)
  product3 = create_product('Апельсины', 100, 10, category1)
  product4 = create_product('Виноград', 100, 10, category1)
  product5 = create_product('Твикс', 100, 10, category2)
  product6 = create_product('Баунти', 100, 10, category2)
  product7 = create_product('Сникерс', 100, 10, category2)
  product8 = create_product('Мармелад', 100, 10, category2)
end
