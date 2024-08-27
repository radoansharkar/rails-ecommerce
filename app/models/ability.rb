class Ability
  include CanCan::Ability

  def initialize(user)
    if user&.admin?
      can :manage, :all
    else
      can :read, :all
      can :email_preview, Order
    end
  end
end