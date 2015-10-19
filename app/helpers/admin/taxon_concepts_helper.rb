module Admin::TaxonConceptsHelper

  DEFAULT_OPTS = {
    klass: 'taxon-concept-multiple',
    multiple: 'multiple',
    data_name_status: 'A'
  }
  def fields_opts f, name_status
    case name_status
    when 'A', 'N'
      DEFAULT_OPTS.merge({
        label: 'Parent',
        klass: 'taxon-concept parent-taxon',
        field_name: :parent_id,
        data_name: f.object.parent.try(:full_name),
        data_name_status: f.object.parent.try(:name_status),
        multiple: ''
      })
    when 'S'
      DEFAULT_OPTS.merge({
        label: "Accepted names",
        field_name: :accepted_name_ids,
        data_name: TaxonConcept.fetch_taxons_full_name(
          f.object.accepted_name_ids
        ).to_s,
      })
    when 'T'
      DEFAULT_OPTS.merge({
        label: "Accepted names",
        field_name: :accepted_names_for_trade_name_ids,
        data_name: TaxonConcept.fetch_taxons_full_name(
          f.object.accepted_names_for_trade_name_ids
        ).to_s,
      })
    when 'H'
      DEFAULT_OPTS.merge({
       klass: 'hybrids-selection',
       label: 'Parents',
       field_name: :hybrid_parent_ids,
       data_name: TaxonConcept.fetch_taxons_full_name(
         f.object.hybrid_parent_ids
       ).to_s,
      })
    end
  end

  def name_status_related_fields f, name_status
    generate_input_form(f, fields_opts(f, name_status))
  end

  def generate_input_form(f, opts={})
    content_tag(:div, class: 'control-group') do
      concat content_tag(:label, opts[:label])
      concat f.text_field(opts[:field_name], {
        :class => opts[:klass],
        :'data-name' => opts[:data_name],
        :'data-name-status' => 'A',
        :'data-name-status-filter' => ['A'].to_json,
        :'data-taxonomy-id' => f.object.taxonomy_id,
        opts[:multiple] => opts[:multiple]
      })
    end
  end
end
