class NomenclatureChange::Split < NomenclatureChange
  has_one :input, :conditions => 'is_input',
    :class_name => NomenclatureChange::Component,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_many :outputs, :conditions => 'NOT is_input',
    :class_name => NomenclatureChange::Component,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true
end
