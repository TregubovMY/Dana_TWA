# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user_role = Role.where(name: 'user').first_or_initialize
user_role.save!
admin_role = Role.where(name: 'admin').first_or_initialize
admin_role.save!
manager_role = Role.where(name: 'manager').first_or_initialize
manager_role.save!

other_category = Category.where(name: 'other').first_or_initialize
other_category.save!

bank = Bank.where(name: 'Sberbank').first_or_initialize
bank.save!

mailing_settings = MailingSetting.where(bank_id: bank.id, active: true, phone: '8 911 111 11 11').first_or_initialize
mailing_settings.save!

mailing = Mailing.where(mailing_setting_id: mailing_settings.id, kind: 0).first_or_initialize
mailing.save!

if Rails.env.development?
  admin = User.where(username: 'admin').first_or_initialize
  admin.update!(password: '123456', password_confirmation: '123456',
                telegram_chat_id: 'admin_id', telegram_username: 'admin',
                deposit: 0, approve: true)

  manager = User.where(username: 'manager').first_or_initialize
  manager.update!(password: '123456', password_confirmation: '123456',
                  telegram_chat_id: 'manager_id', telegram_username: 'manager',
                  deposit: 0, approve: true)

  user = User.where(username: 'user').first_or_initialize
  user.update!(password: '123456', password_confirmation: '123456',
               telegram_chat_id: 'user_id', telegram_username: 'user',
               deposit: 0, approve: true)

  admin_role_create = UsersRole.where(user_id: admin.id, role_id: admin_role.id).first_or_initialize
  admin_role_create.save!

  manager_role_create = UsersRole.where(user_id: manager.id, role_id: manager_role.id).first_or_initialize
  manager_role_create.save!

  user_role_create = UsersRole.where(user_id: user.id, role_id: user_role.id).first_or_initialize
  user_role_create.save!

  category1 = Category.where(name: 'category1').first_or_initialize
  category1.save!
  category2 = Category.where(name: 'category2').first_or_initialize
  category2.save!

  product1 = Product.where(name: 'product1').first_or_initialize
  product1.update!(price: 100, quantity: 10, category_id: category1.id)

  product2 = Product.where(name: 'product2').first_or_initialize
  product2.update!(price: 100, quantity: 10, category_id: category2.id)

  order1 = Order.where(state: :created, user_id: user.id, product_id: product1.id,
                       cancelable_until: 1.month.from_now).first_or_initialize
  order1.save!

  order2 = Order.where(state: :completed, user_id: user.id, product_id: product2.id,
                       cancelable_until: 1.month.from_now).first_or_initialize
  order2.save!

  payment1 = Payment.where(order_id: order1.id).first_or_initialize
  payment1.update!(amount: 100, state: :pending)

  payment2 = Payment.where(order_id: order2.id).first_or_initialize
  payment2.update!(amount: 100, state: :succeeded)
end
