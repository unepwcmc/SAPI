module Admin::TaxonConceptsHelper

  def dynamic_form_fields f, name_status
    if ['A', 'N'].include? name_status
      content_tag(:div, class: 'control-group') do
        concat content_tag(:label, 'Parent')
        concat f.text_field(:parent_scientific_name,
          class: 'typeahead',
          'data-rank-scope' => 'parent')
      end
    elsif ['S', 'T'].include? name_status
      name_ids =
        name_status == 'S' ? :accepted_name_ids : :accepted_names_for_trade_name_ids
      content_tag(:div, class: 'control-group') do
        concat content_tag(:label, 'Accepted names')
        concat f.text_field(name_ids, {
          :class => 'taxon-concept-multiple',
          :'data-name' => TaxonConcept.fetch_taxons_full_name(f.object.send(name_ids)).to_s,
          :'data-name-status' => 'A',
          :'data-name-status-filter' => ['A'].to_json,
          :'data-taxonomy-id' => f.object.taxonomy_id,
          :multiple => 'multiple'
        })
      end
    end
  end
end
