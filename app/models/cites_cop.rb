class CitesCop < Event
  validates :designation_id, :presence => true
  validate :designation_is_cites
  validates :effective_at, :presence => true

  protected
    def designation_is_cites
      cites = Designation.find_by_name('CITES')
      unless designation_id && cites && designation_id == cites.id
        errors.add(:designation_id, 'should be CITES')
      end
    end
end