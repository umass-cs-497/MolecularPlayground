class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new

    can :manage, Scene
    can :manage, Playlist

    # Everyone can see their "my scenes" page
    can :home, :scenes

    # Site admins can see "my installations"
    can :home, :installations unless user.installations.empty?

    if user.admin?
      can :manage, Installation
      can :manage, User
      can :home, :queue
      can :home, :settings

      # Admins can't change other users' passwords
      cannot [:password, :update_password], User do |user_obj|
        user != user_obj
      end

      # Admins can't delete themselves
      cannot [:delete, :destroy], User, id: user.id

    else
      can :read, Installation
      can :read, User
      can [:edit, :update, :password, :update_password], User, id: user.id
    end

  end
end
