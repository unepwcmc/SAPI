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
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new

    if user.is_secretariat? || !user.is_active
      can [:autocomplete, :read, :edit, :new], :all
    elsif user.is_manager?
      can :manage, :all
    elsif user.is_contributor?
      can [:autocomplete, :read], :all
      can :update, :all
      can :create, :all
      cannot :update, User do |u|
        u.id != user.id
      end
      cannot :manage, [
        Taxonomy, Rank, Designation,
        Instrument, SpeciesListing,
        ChangeType, EuDecisionType,
        Language, GeoEntity, GeoEntityType,
        TradeCode, Trade::TaxonConceptTermPair,
        TermTradeCodesPair, Event, CitesSuspension,
        Quota, EuRegulation, EuSuspensionRegulation,
        Trade::Shipment, Trade::Permit, Trade::AnnualReportUpload,
        Trade::ValidationRule
      ]
    elsif !user.is_manager_or_contributor?
      cannot :manage, :all
    end
  end
end
