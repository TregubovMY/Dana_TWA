# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
      can :update, User, %i[username approve deposit password password_confirmation role_id]
      cannot :update, User do |target_user|
        !target_user.admin_or_manager?
      end
    elsif user.manager?
      can :manage, :all
      cannot :delete, User
      cannot :update, User, %i[password password_confirmation role_id]
      cannot :really_destroy, Product
    else
      can :create_for_product, Order
      can :delete_last, Order
      can :users, Product
    end
  end
end
