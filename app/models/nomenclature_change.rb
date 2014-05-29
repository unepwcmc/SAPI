class NomenclatureChange < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :event_id, :updated_by_id,
    :nomenclature_change_inputs_attributes,
    :nomenclature_change_outputs_attributes
  belongs_to :event
  has_many :nomenclature_change_inputs, :conditions => 'is_input',
    :class_name => NomenclatureChangeComponent, :dependent => :destroy
  has_many :nomenclature_change_outputs, :conditions => 'NOT is_input',
    :class_name => NomenclatureChangeComponent, :dependent => :destroy
  accepts_nested_attributes_for :nomenclature_change_inputs, :allow_destroy => true
  accepts_nested_attributes_for :nomenclature_change_outputs, :allow_destroy => true
end
