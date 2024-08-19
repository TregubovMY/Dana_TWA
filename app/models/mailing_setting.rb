class MailingSetting < ApplicationRecord
  acts_as_paranoid

  DEFAULT_MAILING_SETTING_ID = 1

  belongs_to :bank, -> { with_deleted }, dependent: :destroy, inverse_of: :mailing_settings
  has_many :mailings, dependent: :destroy
  has_one_attached :image, dependent: :destroy

  validates :active, inclusion: { in: [true, false] }
  validates :phone, presence: true
end
