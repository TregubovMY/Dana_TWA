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
  scope :approved, -> { where(approve: true) }
  scope :unapproved, -> { where(approve: false) }

  broadcasts_to ->(_user) { "users" }, inserts_by: :prepend

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

  def self.create_user_telegram(telegram_username:, telegram_chat_id:)
    user = new(telegram_username:, telegram_chat_id:, username: telegram_username)
    user.password = Devise.friendly_token
    user.save!
  end
end
