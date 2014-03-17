# == Schema Information
#
# Table name: ranks
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  taxonomic_position :string(255)      default("0"), not null
#  fixed_order        :boolean          default(FALSE), not null
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :taxonomic_position, :fixed_order
  include Dictionary
  build_dictionary :kingdom, :phylum, :class, :order, :family, :subfamily, :genus, :species, :subspecies, :variety

  has_many :taxon_concepts

  validates :name, :presence => true, :uniqueness => true
  validates :taxonomic_position, :presence => true,
    :format => { :with => /\A\d(\.\d*)*\z/, :message => "Use prefix notation, e.g. 1.2" }

  def parent_rank_lower_bound
    parts = taxonomic_position.split('.')
    if parts.length > 1
      parts.slice(0, parts.length - 1).join('.')
    else
      (parts.first.to_i - 1).to_s
    end
  end

  def can_be_deleted?
    !has_protected_name? && !has_dependent_objects?
  end

  # returns ranks in given range
  def self.in_range(lower_rank, higher_rank)
    lower_rank_idx = lower_rank && dict.index(lower_rank) || dict.size - 1
    higher_rank_idx = higher_rank && dict.index(higher_rank) || 0
    dict[higher_rank_idx..lower_rank_idx]
  end

  private

  def has_dependent_objects?
    taxon_concepts.count != 0
  end

  def has_protected_name?
    self.class.dict.include? self.name
  end

end
