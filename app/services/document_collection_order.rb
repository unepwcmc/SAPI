class DocumentCollectionOrder
  def initialize(event_id)
    @event_id = event_id
  end

  def show
    Document.left_joins(
      [ :language, :proposal_details ]
    ).select(
      <<-SQL.squish
        "documents"."id" AS "id",
        "title",
        "proposal_details"."proposal_number" AS "proposal_number",
        "type",
        "languages"."iso_code1" AS language,
        "sort_index"
      SQL
    ).where(
      event_id: @event_id
    ).where(
      'primary_language_document_id IS NULL OR primary_language_document_id = documents.id'
    ).order(
      :sort_index
    )
  end

  def update(id_sort_index_hash)
    id_sort_index_hash.each do |id, sort_index|
      Document.where(
        [
          'id = :id OR primary_language_document_id = :id',
          id: id
        ]
      ).update_all(
        { sort_index: sort_index, updated_at: DateTime.now },
      )
    end

    DocumentSearch.clear_cache
  end
end
