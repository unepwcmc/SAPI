# == Schema Information
#
# Table name: ranks
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  taxonomic_position :string(255)      default("0"), not null
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :taxonomic_position, :fixed_order
  include Dictionary
  build_dictionary :kingdom, :phylum, :class, :order, :family, :subfamily, :genus, :species, :subspecies

  has_many :taxon_concepts

  validates :name, :presence => true, :uniqueness => true
  validates :taxonomic_position, :presence => true

  before_destroy :check_destroy_allowed

  def parent_rank_lower_bound
    parts = taxonomic_position.split('.')
    if parts.length > 1
      parts.slice(0, parts.length - 1).join('.')
    else
      (parts.first.to_i - 1).to_s
    end
  end

  private

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    taxon_concepts.count == 0
  end

end
