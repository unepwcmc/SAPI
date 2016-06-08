# == Schema Information
#
# Table name: nomenclature_change_reassignment_targets
#
#  id                                  :integer          not null, primary key
#  nomenclature_change_reassignment_id :integer          not null
#  nomenclature_change_output_id       :integer          not null
#  created_by_id                       :integer          not null
#  updated_by_id                       :integer          not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#

class NomenclatureChange::ReassignmentTarget < ActiveRecord::Base
  track_who_does_it
  attr_accessible :nomenclature_change_output_id,
    :nomenclature_change_reassignment_id, :note
  belongs_to :output, :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_output_id
  belongs_to :reassignment,
    class_name: 'NomenclatureChange::Reassignment',
    foreign_key: :nomenclature_change_reassignment_id

  validates :reassignment, :presence => true
  validates :output, :presence => true
end
