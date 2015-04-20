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
#  role                   :string(255)      default("default")
#

class User < ActiveRecord::Base
  include SentientUser
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable
  attr_accessible :email, :name, :password, :password_confirmation,
    :remember_me, :role, :terms_and_conditions, :is_cites_authority,
    :organisation, :geo_entity_id

  has_many :ahoy_visits, dependent: :nullify, class_name: 'Ahoy::Visit'
  has_many :ahoy_events, dependent: :nullify, class_name: 'Ahoy::Event'
  has_many :api_requests
  belongs_to :geo_entity

  validates :email, :uniqueness => true, :presence => true
  validates :name, :presence => true
  validates :role, inclusion: { in: ['default', 'admin', 'api'] },
                   presence: true
  validates :organisation, presence: true
  before_create :set_default_role

  def is_contributor?
    self.role == 'default'
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_api?
    self.role == 'api'
  end

  def role_for_display
    case self.role
    when 'default'
      "Contributor"
    when 'admin'
      "Manager"
    when 'api'
      "API User"
    end
  end

  def last_30_days_api_requests
    self.api_requests.group(:response_status).order(:response_status).group_by_day(:created_at, range: 30.days.ago.midnight..Time.now).count
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
