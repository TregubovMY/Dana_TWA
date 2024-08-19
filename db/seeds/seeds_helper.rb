module SeedsHelpers
  extend self

  def create_role(name)
    Role.where(name: name).first_or_initialize.tap(&:save!)
  end

  def create_category(name = nil)
    name ||= Faker::Commerce.department
    Category.where(name: name).first_or_initialize.tap(&:save!)
  end

  def create_product(name = nil, price = nil, quantity = nil, category = nil)
    name ||= Faker::Commerce.product_name
    price ||= Faker::Commerce.price(range: 10.0..100.0)
    quantity ||= rand(1..50)
    category ||= Category.all.sample

    product = Product.where(name: name).first_or_initialize
    product.update!(price: price, quantity: quantity, category: category)

    unless product.image.attached?
      product.image.attach(
        io: File.open(Rails.root.join('app/assets/images/food.jpg')),
        filename: 'default_product.jpg',
        content_type: 'image/jpeg'
      )
    end

    product
  end

  def create_user(username:, password:, role:, telegram_chat_id:, telegram_username:, deposit: 0, approve: true)
    user = User.where(username: username).first_or_initialize
    user.update!(password: password, password_confirmation: password,
                 telegram_chat_id: telegram_chat_id, telegram_username: telegram_username,
                 deposit: deposit, approve: approve)

    UsersRole.where(user: user, role: role).first_or_initialize.tap(&:save!)

    user
  end

  def create_bank(name)
    Bank.where(name: name).first_or_initialize.tap(&:save!)
  end

  def create_mailing_setting(bank, phone: '8 911 111 11 11', active: true)
    MailingSetting.where(bank: bank, phone: phone, active: active).first_or_initialize.tap(&:save!)
  end
end
