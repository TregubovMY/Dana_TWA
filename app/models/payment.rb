class Payment < ApplicationRecord
  acts_as_paranoid

  enum :state, { pending: 0, succeeded: 1, failed: 2 }

  belongs_to :order, -> { with_deleted }, inverse_of: :payment
end
