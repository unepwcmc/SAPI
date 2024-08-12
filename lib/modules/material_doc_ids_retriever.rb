module MaterialDocIdsRetriever
  def self.run(params)
    params['taxon_concepts_ids'] =
      if params['taxon_name'].present?
        exact_match = MTaxonConcept.where('LOWER(full_name) = ?', params['taxon_name'].downcase).
          where(taxonomy_id: 1).
          first

        # retrieve the same taxa as shown in the page
        check_params = params.symbolize_keys
        ids =
          if params['scientific_name'].present? || params['country_ids'].present? || params['cites_appendices'].present?
            check_params[:scientific_name] = params['taxon_name']
            Checklist::Checklist.new(check_params).query.pluck(:id)

          else
            MTaxonConcept.by_cites_eu_taxonomy.
              without_non_accepted.
              without_hidden.
              by_name(
                params['taxon_name'],
                { synonyms: true, common_names: true, subspecies: false }
              ).
              order('rank_id ASC, full_name').
              pluck(:id)
          end

        anc_ids = []
        anc_ids = ancestors_ids(exact_match.try(:id), params['taxon_name'], exact_match).uniq if ids.include?(exact_match.try(:id))
        anc_ids | ids
      elsif params['taxon_concept_id'].present?
        # retrieve all the ancestors taxa given a taxon(included)
        anc_ids = ancestors_ids(params['taxon_concept_id'])
        # retrieve all the children taxa given a taxon(included)
        chi_ids = MTaxonConcept.descendants_ids(params['taxon_concept_id']).map(&:to_i)
        anc_ids | chi_ids
      else
        check_params =
          if params.respond_to?(:permit!)
            params.dup.permit!.to_h.symbolize_keys
          else
            params.symbolize_keys
          end
        Checklist::Checklist.new(check_params).results.map(&:id)
      end

    return [] if params['taxon_concepts_ids'].empty?

    docs = DocumentSearch.new(
      params.merge(show_private: false, per_page: 10_000), 'public'
    )

    ordered_docs = docs.cached_results.sort_by do |doc|
      doc_tc_ids = doc.taxon_concept_ids
      params['taxon_concepts_ids'].index { |id| doc_tc_ids.include? id }
    end

    doc_ids = ordered_docs.map { |doc| locale_document(doc) }.flatten
    doc_ids = doc_ids.pluck('id')
  end

  private

  def self.locale_document(doc)
    document = doc.document_language_versions.select { |h| h['locale_document'] == 'true' }
    document = doc.document_language_versions.select { |h| h['locale_document'] == 'default' } if document.empty?
    document
  end

  def self.ancestors_ids(tc_ids, taxon_name = nil, exact_match = nil)
    # TODO: Raise an error if any of these are not integers instead of leaving
    # it to the db to do this. That logic maybe belongs elsewhere?
    # Consider using `SearchParamSanitiser.sanitise_integer_array` for this.
    tc_ids_array = Array(tc_ids.is_a?(String) ? tc_ids.split(',') : tc_ids)
    tc_ids_sql = tc_ids_array.map(&:to_i).filter { |tc_id| tc_id > 0 }.join(', ')

    # Don't bother running a query if we didn't get any taxon concept ids
    return [] if tc_ids_sql.empty?

    res = ApplicationRecord.connection.execute(
      <<-SQL.squish
      SELECT ancestor_taxon_concept_id
      FROM taxon_concepts_and_ancestors_mview
      WHERE taxon_concept_id IN (#{tc_ids_sql})
      AND ancestor_taxon_concept_id IS NOT NULL
      ORDER BY
        #{order_case(exact_match, taxon_name)}
      tree_distance DESC, ancestor_taxon_concept_id;
      SQL
    )

    res.map(&:values).flatten.map(&:to_i).uniq
  end

  def self.order_case(match, taxon_name)
    return '' if taxon_name.present? && match.nil?
    query = "CASE
              WHEN taxon_concept_id = ancestor_taxon_concept_id
            "
    query += " AND taxon_concept_id = #{match.id} " if match
    query += " THEN -1
              END, "
    query
  end
end
