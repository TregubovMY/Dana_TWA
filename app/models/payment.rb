class Payment < ApplicationRecord
  acts_as_paranoid

  belongs_to :order, -> { with_deleted }, inverse_of: :payments
end
