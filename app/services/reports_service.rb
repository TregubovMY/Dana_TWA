# TODO: Убрать ненужные запросы из базы данных (сделать за пару запросов)
class ReportsService
  def self.summarize_price_and_count(orders)
    order_ids = orders.pluck(:id)
    payments = Payment.where(order_id: order_ids)

    [payments.sum(&:amount), orders.count]
  end


  # Суммирует цену заказов и подсчитывает количество заказов для всех пользователей
  def self.summarize_price_and_count_orders(users)
    orders_summary = Order.joins(:payment)
                          .where(user: users)
                          .select('SUM(payments.amount) AS total_price, COUNT(orders.id) AS total_count').take

    [orders_summary.total_price.to_f, orders_summary.total_count]
  end

  # Долг: суммирует цену заказов и количество не оплаченных заказов для одного пользователя
  def self.summarize_price_created_orders_for(user)
    orders_summary = user.orders
                         .joins(:payment)
                         .where(state: :created)
                         .select('SUM(payments.amount) AS total_price').take

    orders_summary.total_price.to_f
  end

  def self.summarize_price_and_count_orders_users_this_month(user)
    orders = user.orders.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)
    summarize_price_and_count(orders)
  end

  def self.summarize_price_and_count_orders_users_last_month(user)
    orders = user.orders.where(created_at: Date.today.prev_month.beginning_of_month..Date.today.prev_month.end_of_month)
    summarize_price_and_count(orders)
  end
end
