module MaterialDocIdsRetriever

  def self.run(params)
    params[:taxon_concepts_ids] =
      if params[:taxon_name].present?
        # retrieve the same taxa as shown in the page
        MTaxonConcept.by_cites_eu_taxonomy
                     .without_non_accepted
                     .without_hidden
                     .by_name(
                        params[:taxon_name],
                        { :synonyms => true, :common_names => true, :subspecies => false }
                       )
                     .pluck(:id)
      elsif params[:taxon_concept_id].present?
        #retrieve all the children taxa given a taxon(included)
        MTaxonConcept.descendants_ids(params[:taxon_concept_id])
      end

    docs = DocumentSearch.new(
      params.merge(show_private: false, per_page: 10_000), 'public'
    )

    doc_ids = docs.cached_results.map { |doc| locale_document(doc) }.flatten
    doc_ids = doc_ids.map{ |d| d['id'] }
  end

  private

  def self.document_language_versions(doc)
    JSON.parse(doc.document_language_versions)
  end

  def self.locale_document(doc)
    document = document_language_versions(doc).select { |h| h['locale_document'] == 'true' }
    document = document_language_versions(doc).select { |h| h['locale_document'] == 'default' } if document.empty?
    document
  end

end
