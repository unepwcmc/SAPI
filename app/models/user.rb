# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  authentication_token   :string(255)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  is_active              :boolean          default(TRUE), not null
#  is_cites_authority     :boolean          default(FALSE), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  name                   :string(255)      not null
#  organisation           :text             default("UNKNOWN"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role                   :text             default("api"), not null
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  geo_entity_id          :integer
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  include Deletable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :email, :name, :password, :password_confirmation,
  #   :remember_me, :role, :terms_and_conditions, :is_cites_authority,
  #   :organisation, :geo_entity_id, :is_active

  MANAGER = 'admin'
  CONTRIBUTOR = 'default' # nonsense
  ELIBRARY_USER = 'elibrary'
  API_USER = 'api'
  SECRETARIAT = 'secretariat'
  ROLES = [ MANAGER, CONTRIBUTOR, ELIBRARY_USER, API_USER, SECRETARIAT ]
  NON_ADMIN_ROLES = [ ELIBRARY_USER, API_USER, SECRETARIAT ]
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
  belongs_to :geo_entity, optional: true

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }, presence: true
  validates :organisation, presence: true
  before_create :set_default_role
  after_commit :sync_with_captive_breeding_db

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
      if tracked_objects[i].where([ 'created_by_id = :id OR updated_by_id = :id', id: self.id ]).limit(1).count > 0
        return false
      end
    end
    true
  end

protected

  def self.searchable_text_columns
    columns.select do |col|
      [ :text, :string ].include? col.type
    end.map(&:name) - [
      'reset_password_token',
      'authentication_token',
      'encrypted_password'
    ]
  end

private

  def set_default_role
    self.role ||= 'api'
  end

  # https://github.com/heartcombo/devise/tree/v4.4.3#active-job-integration
  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  def sync_with_captive_breeding_db
    # Only interested if role, name, encrypted_password, and email is changed.
    # Or user deleted.
    return unless (previous_changes.keys & %w[email role name encrypted_password]).present? || destroyed?

    role_was = previous_changes['role']&.first
    action =
      if destroyed? # User record deleted.
        :delete
      elsif is_elibrary_user? || is_manager? # Is admin or elibrary.
        :create_or_update
      elsif role_was == MANAGER || role_was == ELIBRARY_USER # Was admin or elibrary.
        :delete
      else
        :none
      end
    return if action == :none

    email_was = previous_changes['email']&.first
    existing_cb_users = []
    existing_cb_users << CaptiveBreedingUser.find_by(email:)
    existing_cb_users << CaptiveBreedingUser.find_by(email: email_was) if email_was.present?
    existing_cb_users = existing_cb_users.compact # Remove nil

    if action == :delete && existing_cb_users.present?
      # TODO: Do not have requirement for this yet, not sure is it safe to delete.
      # https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/241
      # https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/232
    elsif action == :create_or_update
      if existing_cb_users.blank?
        CaptiveBreedingUser.create!(email:, name:, encrypted_password:)
      else # Update the first CB user record, which is using the new email address (if changed).
        existing_cb_users.first.update!(email:, name:, encrypted_password:)
        if existing_cb_users[1].present? # Duplicate user!? Remove it?
          # TODO: Do not have requirement for this yet, not sure is it safe to delete.
          # https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/241
          # https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/232
        end
      end
    end
  end
end
