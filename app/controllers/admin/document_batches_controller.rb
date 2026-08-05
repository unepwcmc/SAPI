# /admin/event/:event_id/document_batch
# /admin/document_batch
class Admin::DocumentBatchesController < Admin::StandardAuthorizationController
  def new
    load_associations

    @document_batch = DocumentBatch.new(
      event_id: @event.try(:id),
      date: @event.try(:published_at_formatted),
      language_id: @english.id,
      is_public: false
    )
  end

  def create
    @event = Event.find(params[:event_id]) if params[:event_id]
    @document_batch = DocumentBatch.new(document_batch_params)

    if @document_batch.save
      if @event
        redirect_to admin_event_documents_url(@event)
      else
        redirect_to admin_documents_url
      end
    else
      load_associations
      render 'new'
    end
  end

protected

  def load_associations
    @event = Event.find(params[:event_id]) if params[:event_id]
    @languages = Language.select([ :id, :name_en, :name_es, :name_fr ]).order(:name_en)
    @english = Language.find_by(iso_code1: 'EN')
    @document_types =
      if @event
        @event.class.elibrary_document_types.map { |l| [ l.display_name, l.name ] }
      else
        Document.elibrary_document_types.map { |l| [ l.display_name, l.name ] }
      end
  end

  def document_batch_params
    document_batch = params.expect(
      document_batch: [
        :event_id,
        :date,
        :language_id,
        :is_public,
        files: []
      ]
    )
    raw_documents_attributes = params.dig(:document_batch, :documents_attributes)

    # The batch-upload JavaScript submits nested fields as
    # `documents_attributes[0][type]`, which Rails parses into a hash keyed by
    # "0", "1", etc. Normalize that browser payload into the array shape
    # expected by `DocumentBatch`, while still accepting callers that already
    # send an array.
    document_batch[:documents_attributes] =
      normalized_documents_attributes(raw_documents_attributes)

    document_batch
  end

  def normalized_documents_attributes(documents_attributes)
    case documents_attributes
    when nil
      nil
    when Array
      documents_attributes.map { |attributes| normalize_document_attributes(attributes) }
    else
      documents_attributes.permit!.to_h.sort_by do |key, _|
        Integer(key.to_s, 10)
      rescue ArgumentError, TypeError
        key.to_s
      end.map { |_, attributes| normalize_document_attributes(attributes) }
    end
  end

  def normalize_document_attributes(attributes)
    attributes =
      if attributes.respond_to?(:permit)
        attributes.permit(:type).to_h
      elsif attributes.respond_to?(:to_h)
        attributes.to_h
      else
        attributes
      end

    {
      type: attributes[:type] || attributes['type']
    }
  end
end
