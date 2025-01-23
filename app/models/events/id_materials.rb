# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  description          :text
#  effective_at         :datetime
#  end_date             :datetime
#  extended_description :text
#  is_current           :boolean          default(FALSE), not null
#  multilingual_url     :text
#  name                 :string(255)
#  private_url          :text
#  published_at         :datetime
#  subtype              :string(255)
#  type                 :string(255)      default("Event"), not null
#  url                  :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  designation_id       :integer
#  elib_legacy_id       :integer
#  legacy_id            :integer
#  updated_by_id        :integer
#
# Indexes
#
#  idx_events_where_is_current_on_type_subtype_designation  (type,subtype,designation_id) WHERE is_current
#  index_events_on_created_by_id                            (created_by_id)
#  index_events_on_designation_id                           (designation_id)
#  index_events_on_name                                     (name) UNIQUE
#  index_events_on_type_and_subtype_and_designation_id      (type,subtype,designation_id)
#  index_events_on_updated_by_id                            (updated_by_id)
#
# Foreign Keys
#
#  events_created_by_id_fk   (created_by_id => users.id)
#  events_designation_id_fk  (designation_id => designations.id)
#  events_updated_by_id_fk   (updated_by_id => users.id)
#

# Cites Animal Committee

class IdMaterials < Event
  def self.elibrary_document_types
    [
      Document::IdManual,
      Document::VirtualCollege
    ]
  end
end
