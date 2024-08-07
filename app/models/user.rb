class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
  acts_as_paranoid

  validates :username, presence: true, uniqueness: true

  has_many :roles_users, -> { with_deleted }, dependent: :destroy
  has_one :role, through: :roles_users

  def email_required?
    false
  end
end
