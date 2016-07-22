class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(account_type: 'manager')

    can :manage, :all
  end
end
