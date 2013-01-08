# == Schema Information
#
# Table name: ranks
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :parent_id
  include Dictionary
  build_dictionary :kingdom, :phylum, :class, :order, :family, :subfamily, :genus, :species, :subspecies

  belongs_to :parent, :class_name => Rank
  has_many :taxon_concepts

  validates :name, :presence => true, :uniqueness => true

  before_destroy :check_destroy_allowed

  scope :above_rank, lambda { |rank_id|
    joins <<-SQL
    INNER JOIN (
      WITH RECURSIVE q AS (
        SELECT h, h.id FROM ranks h WHERE id = #{rank_id}
        UNION ALL
        SELECT hi, hi.id FROM q JOIN ranks hi ON (q.h).parent_id = hi.id
      )
      SELECT id FROM q WHERE id <> #{rank_id}
    ) ranks_above ON ranks_above.id = #{table_name}.id
  SQL
  }

  scope :below_rank, lambda { |rank_id|
    joins <<-SQL
    INNER JOIN (
      WITH RECURSIVE q AS (
        SELECT h, h.id FROM ranks h WHERE id = #{rank_id}
        UNION ALL
        SELECT hi, hi.id FROM q JOIN ranks hi ON (q.h).id = hi.parent_id
      )
      SELECT id FROM q WHERE id <> #{rank_id}
    ) ranks_above ON ranks_above.id = #{table_name}.id
  SQL
  }

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
