class PaymentsService
  def self.pay_all_orders(orders)
    ActiveRecord::Base.transaction do
      orders.each do |order|
        order.update!(state: :completed)
        order.payment.update!(state: :succeeded)
      end
    end
  end

  def self.process_orders_sequentially_at(user)
    orders = user.orders.where(state: :created).includes(:payment).order(created_at: :desc)

    orders.each do |order|
      user.update!(deposit: user.deposit - order.payment.amount)
      order.update!(state: :completed)
      order.payment.update!(state: :succeeded)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error { "Failed to process order for user #{user.id}: #{e.message}" }
  end
end
