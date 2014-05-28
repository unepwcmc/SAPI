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
#  is_manager             :boolean
#

class User < ActiveRecord::Base
  include SentientUser
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable
  attr_accessible :email, :name, :password, :password_confirmation,
    :remember_me, :is_manager

  validates :email, :uniqueness => true, :presence => true
  validates :name, :presence => true


  def is_contributor?
    !is_manager?
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

end
