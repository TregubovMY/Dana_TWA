class ReportsService
  def self.summarize_orders_price(orders)
    order_ids = orders.pluck(:id)
    payments = Payment.where(order_id: order_ids)
    payments.sum(&:amount)
  end

  def self.summarize_price_orders_users(users)
    users.sum { |user| summarize_orders_price(user.orders) }
  end

  def self.summarize_price_orders_users_last_month(users)
    users.sum do |user|
      summarize_orders_price(user.orders.where(created_at: Time.today.prev_month..Time.today.prev_month.end_of_month))
    end
  end

  def self.count_orders(users)
    users.sum(&:count_orders)
  end
end
