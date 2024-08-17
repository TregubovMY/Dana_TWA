module PaymentsHelper
  def payment_states
    Payment.states.map { |state| [t("activerecord.attributes.payment.#{state[0]}"), state[1]] }
  end
end
