class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable, authentication_keys: [:username]

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def email_required?
    false
  end
end
