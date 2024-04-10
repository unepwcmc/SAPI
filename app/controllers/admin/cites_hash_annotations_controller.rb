class Admin::CitesHashAnnotationsController < Admin::HashAnnotationsController
  protected

  def load_collection
    end_of_association_chain.for_cites
  end

  def load_associations
    @events = CitesCop.order(:effective_at)
  end

  private

  def cites_hash_annotation_params
    params.require(:annotation).permit(
      # attributes were in model `attr_accessible`.
      :listing_change_id, :symbol, :parent_symbol, :short_note_en,
      :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
      :display_in_index, :display_in_footnote, :event_id
    )
  end
end
