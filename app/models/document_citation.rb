# == Schema Information
#
# Table name: document_citations
#
#  id             :integer          not null, primary key
#  document_id    :integer
#  created_by_id  :integer
#  updated_by_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  elib_legacy_id :integer
#

class DocumentCitation < ActiveRecord::Base
  track_who_does_it
  attr_accessible :document_id, :stringy_taxon_concept_ids, :geo_entity_ids
  has_many :document_citation_taxon_concepts, dependent: :destroy, autosave: true
  has_many :taxon_concepts, through: :document_citation_taxon_concepts
  has_many :document_citation_geo_entities, dependent: :destroy, autosave: true
  has_many :geo_entities, through: :document_citation_geo_entities
  belongs_to :document, touch: true

  # the following two amazing methods are here to handle input from select2
  # which in case of ajax populated multiple selects comes as a comma sep list
  def stringy_taxon_concept_ids
    taxon_concept_ids.join(',')
  end

  def stringy_taxon_concept_ids=(ids)
    self.taxon_concept_ids = ids.split(',')
  end

  after_destroy do |dc|
    dc.document.touch
  end

  def duplicates(comparison_attributes_override = {})
    taxon_concept_id = comparison_attributes_override.delete(:taxon_concept_id)

    relation = DocumentCitation.
      select('document_citations.*').
      where(document_id: self.document_id).
      includes(:document_citation_taxon_concepts).
      where('document_citation_taxon_concepts.taxon_concept_id' => taxon_concept_id)
    geo_entities_ids = document_citation_geo_entities.pluck(:geo_entity_id)
    if !geo_entities_ids.empty?
      relation = relation.joins(
        ActiveRecord::Base.send(:sanitize_sql_array, [
          "JOIN (
            SELECT document_citation_id, CASE
              WHEN ARRAY_AGG(geo_entity_id) @> ARRAY[:geo_entities_ids]::INT[] THEN TRUE
              ELSE FALSE
            END AS geo_entities_match
            FROM document_citation_geo_entities
            GROUP BY document_citation_id
          ) s ON s.document_citation_id = document_citations.id AND s.geo_entities_match",
          geo_entities_ids: geo_entities_ids
        ])
      )
    end
    relation
  end

end
