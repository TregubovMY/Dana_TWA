# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      can :update, User, %i[username approve deposit role_id password password_confirmation]
    elsif user.manager?
      can :manage, :all
      cannot :delete, User
      cannot :update, User, %i[password password_confirmation role_id]
      cannot :really_destroy, Product
    else
      can :create_for_product, Order
      can :delete_last, Order
      can :users, Order
    end
  end
end
