class Admin::EuHashAnnotationsController < Admin::HashAnnotationsController
protected

  def load_collection
    end_of_association_chain.for_eu
  end

  def load_associations
    @events = EuRegulation.order(:effective_at)
  end

private

  def eu_hash_annotation_params
    params.require(:annotation).permit(
      # attributes were in model `attr_accessible`.
      :listing_change_id, :symbol, :parent_symbol, :short_note_en,
      :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
      :display_in_index, :display_in_footnote, :event_id
    )
  end
end
