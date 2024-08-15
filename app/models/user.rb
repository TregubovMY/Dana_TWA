class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  acts_as_paranoid

  has_one :users_role, -> { with_deleted }, dependent: :destroy, inverse_of: :user
  has_one :role, through: :users_role
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  validates :username, presence: true, uniqueness: true
  validates :telegram_chat_id, presence: true, uniqueness: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }

  scope :filter_by_name, ->(name) { where('username ILIKE :query', query: "%#{name}%") }
  scope :filter_by_date, ->(start_date, end_date) { where(orders: { created_at: start_date..end_date }) }
  scope :filter_by_state, ->(state) { joins(:orders).merge(Order.filter_by_state(state)) }
  scope :approved, -> { where(approve: true) }
  scope :unapproved, -> { where(approve: false) }

  def email_required?
    false
  end

  def approve!
    update!(approve: true)
  end

  def admin?
    role.name == 'admin'
  end

  def manager?
    role.name == 'manager'
  end

  def admin_or_manager?
    admin? || manager?
  end

  def count_orders
    orders.count
  end

  def summarize_orders_price
    orders.includes(:payment).sum('payments.amount')
  end

  # def really_destroy_with_dependents
  #   user_orders = Order.with_deleted.where(user_id: @user.id)
  #
  #   ActiveRecord::Base.transaction do
  #     user_orders.each do |order|
  #       Payment.with_deleted.find(order.id).really_destroy!
  #       order.really_destroy!
  #     end
  #
  #     really_destroy!
  #   end
  # end

  def self.create_user_telegram(telegram_username:, telegram_chat_id:)
    role = Role.find_by(name: 'user')

    User.transaction do
      user = create!(telegram_username:,
                     telegram_chat_id:,
                     username: telegram_username,
                     password: Devise.friendly_token)
      UsersRole.create!(user:, role:)
    end
  end
end
