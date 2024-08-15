class Bank < ApplicationRecord
  acts_as_paranoid

  has_many :mailing_settings, dependent: :destroy

  validates :name, presence: true
end
