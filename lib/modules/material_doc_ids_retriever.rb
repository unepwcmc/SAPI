module MaterialDocIdsRetriever

  def self.run(params)
    params['taxon_concepts_ids'] =
      if params['taxon_name'].present?
        exact_match = MTaxonConcept.where("LOWER(full_name) = ?", params['taxon_name'].downcase)
                                   .where(taxonomy_id: 1)
                                   .first

        # retrieve the same taxa as shown in the page
        ids = MTaxonConcept.by_cites_eu_taxonomy
                           .without_non_accepted
                           .without_hidden
                           .by_name(
                              params['taxon_name'],
                              { :synonyms => true, :common_names => true, :subspecies => false }
                             )
                           .order('rank_id ASC')
                           .pluck(:id)

        anc_ids = ancestors_ids(ids.join(','), params['taxon_name'], exact_match).uniq
      elsif params['taxon_concept_id'].present?
        # retrieve all the ancestors taxa given a taxon(included)
        anc_ids = ancestors_ids(params['taxon_concept_id'])
        #retrieve all the children taxa given a taxon(included)
        chi_ids = MTaxonConcept.descendants_ids(params['taxon_concept_id']).map(&:to_i)
        anc_ids | chi_ids
      end

    docs = DocumentSearch.new(
      params.merge(show_private: false, per_page: 10_000), 'public'
    )

    ordered_docs = docs.cached_results.sort_by do |doc|
      doc_tc_ids = doc.taxon_concept_ids.gsub(/[{}]/, '').split(',').map(&:to_i)
      params['taxon_concepts_ids'].index{ |id| doc_tc_ids.include? id }
    end

    doc_ids = ordered_docs.map { |doc| locale_document(doc) }.flatten
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

  def self.ancestors_ids(tc_ids, taxon_name = nil, exact_match = nil)
    res = ActiveRecord::Base.connection.execute(
      <<-SQL
      SELECT ancestor_taxon_concept_id
      FROM taxon_concepts_and_ancestors_mview
      WHERE taxon_concept_id IN (#{tc_ids})
      AND ancestor_taxon_concept_id IS NOT NULL
      ORDER BY
        #{order_case(exact_match, taxon_name)}
      tree_distance DESC, ancestor_taxon_concept_id;
      SQL
    )
    res.map(&:values).flatten.map(&:to_i).uniq
  end

  def self.order_case(match, taxon_name)
    return '' if (taxon_name.present? && match.nil?)
    query = "CASE
              WHEN taxon_concept_id = ancestor_taxon_concept_id
            "
    query += " AND taxon_concept_id = #{match.id} " if match
    query += " THEN -1
              END, "
    query
  end
end
