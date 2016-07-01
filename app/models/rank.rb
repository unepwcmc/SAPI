# == Schema Information
#
# Table name: ranks
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  taxonomic_position :string(255)      default("0"), not null
#  fixed_order        :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  display_name_en    :text             not null
#  display_name_es    :text
#  display_name_fr    :text
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :display_name_en, :display_name_es, :display_name_fr,
    :taxonomic_position, :fixed_order
  include Dictionary
  build_dictionary :kingdom, :phylum, :class, :order, :family, :subfamily, :genus, :species, :subspecies, :variety

  translates :display_name

  has_many :taxon_concepts

  validates :name, :presence => true, :uniqueness => true
  validates :display_name_en, :presence => true, :uniqueness => true
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
    super() && !has_protected_name?
  end

  # returns ranks in given range
  def self.in_range(lower_rank, higher_rank)
    lower_rank_idx = lower_rank && dict.index(lower_rank) || dict.size - 1
    higher_rank_idx = higher_rank && dict.index(higher_rank) || 0
    dict[higher_rank_idx..lower_rank_idx]
  end

  def parent_rank_name
    if [Rank::SUBSPECIES, Rank::VARIETY].include?(name)
      Rank::SPECIES
    elsif name != Rank::KINGDOM
      rank_index = self.class.dict.index(name)
      self.class.dict[rank_index - 1]
    else
      nil
    end
  end

  private

  def dependent_objects_map
    {
      'taxon concepts' => taxon_concepts
    }
  end

  def has_protected_name?
    self.class.dict.include? self.name
  end

end
