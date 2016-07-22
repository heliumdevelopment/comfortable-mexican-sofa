class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Comfy::User.new(account_type: 'manager')

    can :manage, :all
  end
end
