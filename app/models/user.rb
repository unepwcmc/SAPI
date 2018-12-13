# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role                   :text             default("api"), not null
#  authentication_token   :string(255)
#  organisation           :text             default("UNKNOWN"), not null
#  geo_entity_id          :integer
#  is_cites_authority     :boolean          default(FALSE), not null
#

class User < ActiveRecord::Base
  include SentientUser
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable
  attr_accessible :email, :name, :password, :password_confirmation,
    :remember_me, :role, :terms_and_conditions, :is_cites_authority,
    :organisation, :geo_entity_id, :is_active

  MANAGER = 'admin'
  CONTRIBUTOR = 'default' # nonsense
  ELIBRARY_USER = 'elibrary'
  API_USER = 'api'
  SECRETARIAT = 'secretariat'
  ROLES = [MANAGER, CONTRIBUTOR, ELIBRARY_USER, API_USER, SECRETARIAT]
  NON_ADMIN_ROLES = [ELIBRARY_USER, API_USER, SECRETARIAT]
  ROLES_FOR_DISPLAY = {
    MANAGER => 'Manager',
    CONTRIBUTOR => 'Contributor',
    ELIBRARY_USER => 'E-library User',
    API_USER => 'API User',
    SECRETARIAT => 'Secretariat'
  }

  has_many :ahoy_visits, dependent: :nullify, class_name: 'Ahoy::Visit'
  has_many :ahoy_events, dependent: :nullify, class_name: 'Ahoy::Event'
  has_many :api_requests
  belongs_to :geo_entity

  validates :email, :uniqueness => true, :presence => true
  validates :name, :presence => true
  validates :role, inclusion: { in: ROLES }, presence: true
  validates :organisation, presence: true
  before_create :set_default_role

  def is_manager?
    self.role == MANAGER
  end

  def is_manager_or_secretariat?
    is_manager? || is_secretariat?
  end

  def is_contributor?
    self.role == CONTRIBUTOR
  end

  def is_elibrary_user?
    self.role == ELIBRARY_USER
  end

  def is_api_user?
    self.role == API_USER
  end

  def is_secretariat?
    self.role == SECRETARIAT
  end

  def is_manager_or_contributor?
    is_manager? || is_contributor?
  end

  def is_manager_or_contributor_or_secretariat?
    is_manager_or_contributor? || is_secretariat?
  end

  def is_api_user_or_secretariat?
    is_api_user? || is_secretariat?
  end

  def role_for_display
    ROLES_FOR_DISPLAY[self.role] || '(empty)'
  end

  def can_be_deleted?
    tracked_objects = [
      TaxonConcept, TaxonRelationship, CommonName, TaxonCommon,
      Event, Distribution, ListingDistribution, Annotation,
      ListingChange, TradeRestriction, EuDecision, TaxonInstrument,
      TradeRestrictionPurpose, TradeRestrictionSource, TradeRestrictionTerm,
      Reference, TaxonConceptReference, DistributionReference,
      Trade::AnnualReportUpload, Trade::Shipment
    ]
    for i in 0..tracked_objects.length - 1
      if tracked_objects[i].where(['created_by_id = :id OR updated_by_id = :id', :id => self.id]).limit(1).count > 0
        return false
      end
    end
    true
  end

  private

  def set_default_role
    self.role ||= 'api'
  end

end
