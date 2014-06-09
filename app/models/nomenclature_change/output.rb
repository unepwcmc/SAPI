# Represents an output of a nomenclature change.
# Outputs may be new taxon concepts, crated as a result of the nomenclature
# change.
class NomenclatureChange::Output < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :new_author_year, :new_full_name, :new_name_status, :new_parent_id, :new_rank_id, :new_taxon_concept_id, :nomenclature_change_id, :note, :taxon_concept_id, :updated_by_id
  belongs_to :taxon_concept
  has_many :reassignment_targets, :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy
  belongs_to :new_parent, :foreign_key => :new_parent_id
  validates_presence_of :new_full_name, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_author_year, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_name_status, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_parent_id, :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates_presence_of :new_rank_id, :if => Proc.new { |c| c.taxon_concept_id.blank? }
end
