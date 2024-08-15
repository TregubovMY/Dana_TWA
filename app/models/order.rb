class Order < ApplicationRecord
  acts_as_paranoid

  enum :state, { created: 0, completed: 1, cancelled: 2 }, _prefix: true

  belongs_to :product, -> { with_deleted }, inverse_of: :orders
  belongs_to :user, -> { with_deleted }, inverse_of: :orders
  has_one :payment, dependent: :destroy

  after_create :set_cancelable_until
  after_create :create_payment
  after_create :change_product_quantity # TODO: дичь нужно делать в контроллере

  scope :filter_by_user, ->(name) { joins(:user).merge(User.filter_by_name(name)) }
  scope :filter_by_date, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :filter_by_state, ->(state) { joins(:payment).where(state:) }
  scope :filter_by_product, ->(product_id) { where(product_id:) }

  def create_payment
    Payment.create(amount: product.price, order: self, state: :pending)
  end

  def set_cancelable_until
    self.cancelable_until = 5.minutes.from_now
    Rails.logger.info "Set cancelable until: #{cancelable_until}!!!"
  end

  def cancelled?
    state == :cancel ? false : cancelable_until > Time.zone.now
  end

  def change_product_quantity
    Rails.logger.info "Before change - Product quantity: #{product.quantity}, state: #{state}"

    if cancelled?
      Rails.logger.info "State is cancelled, incrementing quantity."
      product.increment!(:quantity, 1)
    elsif created?
      Rails.logger.info "State is created, decrementing quantity."
      product.decrement!(:quantity, 1)
    end

    Rails.logger.info "After change - Product quantity: #{product.quantity}, state: #{state}"
  end
end
