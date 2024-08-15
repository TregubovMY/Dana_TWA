class Mailing < ApplicationRecord
  belongs_to :mailing_setting, -> { with_deleted }, dependent: :destroy, inverse_of: :mailings

  enum kind: { distribution_to_debtors: 0 }

  has_one_attached :image
end
