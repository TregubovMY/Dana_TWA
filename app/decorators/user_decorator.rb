class UserDecorator < Draper::Decorator
  delegate_all

  def name_with_sign
    "@#{object.username}"
  end
end
