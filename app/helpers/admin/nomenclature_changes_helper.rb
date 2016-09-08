module Admin::NomenclatureChangesHelper

  def nomenclature_change_form(submit_label = 'Next', &block)
    nested_form_for @nomenclature_change, url: wizard_path, method: :put,
      html: { class: 'form-horizontal' } do |f|
      html = error_messages_for(@nomenclature_change)
      html += capture { block.yield(f) } if block_given?
      html += nomenclature_change_form_buttons(f, submit_label)
      html += progress_bar
      html.html_safe
    end
  end

  def nomenclature_change_form_buttons(f, submit_label)
    content_tag(:div, class: 'clearfix') do
      concat link_to('Cancel', admin_nomenclature_changes_path,
        class: 'pull-left btn btn-link')
      concat ' '
      concat f.submit(submit_label, class: 'pull-right btn btn-primary')
      concat ' '
      concat link_to('Previous ', previous_wizard_path(:back => true),
        class: 'pull-right btn btn-link')
    end
  end

  def progress_bar
    content_tag(:div, class: 'progress') do
      content_tag(:div, class: 'bar',
        style: "width:#{(wizard_steps.index(step).to_f / wizard_steps.size) * 100}%"
      ) do; end
    end
  end

  def print_summary(summary)
    if summary.kind_of?(Array)
      content_tag(:ul) do
        summary.each { |line| concat print_summary(line) }
      end
    else
      content_tag(:li, summary)
    end
  end

  def split_blurb
    content_tag(:div, class: 'well well-small') do
      concat 'Splitting '
      concat link_to(
        @nomenclature_change.input.taxon_concept.full_name,
        admin_taxon_concept_names_path(@nomenclature_change.input.taxon_concept)
      )
      concat split_outputs_blurb
    end
  end

  def split_outputs_blurb
    return '' if @nomenclature_change.outputs.empty? ||
      @nomenclature_change.outputs.map(&:display_full_name).compact.empty?
    html = ' into '
    total = @nomenclature_change.outputs.size
    @nomenclature_change.outputs.each_with_index do |output, idx|
      if output.taxon_concept && !output.new_full_name
        html += link_to(
          output.taxon_concept.full_name,
          admin_taxon_concept_names_path(output.taxon_concept)
        )
      else
        html += content_tag(:span, output.display_full_name)
      end
      html += ', ' if idx < (total - 1)
    end
    html.html_safe
  end

  def lump_blurb
    content_tag(:div, class: 'well well-small') do
      concat 'Lumping '
      total = @nomenclature_change.inputs.size
      @nomenclature_change.inputs.each_with_index do |input, idx|
        if input.taxon_concept
          concat link_to(
            input.taxon_concept.full_name,
            admin_taxon_concept_names_path(input.taxon_concept)
          )
        end
        concat ', ' if idx < (total - 1)
      end
      concat lump_outputs_blurb
    end
  end

  def lump_outputs_blurb
    return '' if @nomenclature_change.output.nil? ||
      @nomenclature_change.output.display_full_name.blank?
    html = ' into '
    if @nomenclature_change.output.taxon_concept && !@nomenclature_change.output.new_full_name
      html += link_to(
        @nomenclature_change.output.taxon_concept.full_name,
        admin_taxon_concept_names_path(@nomenclature_change.output.taxon_concept)
      )
    else
      html += content_tag(:span, @nomenclature_change.output.display_full_name)
    end
    html.html_safe
  end

  def status_change_blurb
    content_tag(:div, class: 'well well-small') do
      concat 'Changing status of '
      concat link_to(
        @nomenclature_change.primary_output.taxon_concept.full_name,
        admin_taxon_concept_names_path(@nomenclature_change.primary_output.taxon_concept)
      )
      concat " from #{@nomenclature_change.primary_output.taxon_concept.name_status}"
      concat " to #{@nomenclature_change.primary_output.new_name_status}"
      concat status_change_swap_blurb
    end
  end

  def status_change_swap_blurb
    return '' unless @nomenclature_change.is_a?(NomenclatureChange::StatusSwap) &&
      @nomenclature_change.secondary_output.taxon_concept
    html = ' (status swap with '
    html += link_to(
      @nomenclature_change.secondary_output.taxon_concept.full_name,
      admin_taxon_concept_names_path(@nomenclature_change.secondary_output.taxon_concept)
    )
    html += ')'
    html.html_safe
  end

  def global_selection(checked = true)
    html = content_tag(:p, content_tag(:i, nil, class: "icon-info-sign") +
      "Select a taxon below to populate all fields with that taxon.")
    @nomenclature_change.outputs.map do |output|
      html += content_tag(:div, class: 'species-checkbox') do
        tag("input", { type: "checkbox", class: 'select-partial-checkbox', checked: checked }) +
        content_tag(:span, output.display_full_name, class: 'species-name')
      end
    end
    html.html_safe
  end

  def outputs_selection(ff)
    ff.object.output_type ||=
      if ff.object.taxon_concept_id.nil?
        'new_taxon'
      elsif ff.object.taxon_concept &&
        !ff.object.new_scientific_name.blank? &&
        ff.object.taxon_concept.full_name != ff.object.new_scientific_name
        # this scenario occurrs when an existing taxon will change name
        'existing_subspecies'
      else
        'existing_taxon'
      end
    content_tag(:div, class: 'outputs_selection') do
      ['New taxon', 'Existing subspecies', 'Existing taxon'].each do |opt|
        opt_val = opt.downcase.gsub(/\s+/, '_')
        concat content_tag(:span,
          ff.radio_button(
            :output_type,
            opt_val,
            { class: 'output-radio' }
          ) + ' ' + opt
        )
      end
      concat ff.link_to_remove 'Remove output'
    end
  end

  def nomenclature_change_header
    case
    when @nc.is_a?(NomenclatureChange::Split)
      concat content_tag(:h1, "NomenclatureChange #{@nc.id} - SPLIT", nil)
      content_tag(:div, @nc.input.note_en.html_safe, class: 'well well-small')
    when @nc.is_a?(NomenclatureChange::Lump)
      concat content_tag(:h1, "NomenclatureChange #{@nc.id} - LUMP", nil)
      content_tag(:div, @nc.output.note_en.html_safe, class: 'well well-small')
    when @nc.is_a?(NomenclatureChange::StatusSwap)
      content_tag(:h1, "NomenclatureChange #{@nc.id} - STATUS SWAP", nil) +
      content_tag(:div, @nc.primary_output.internal_note.html_safe, class: 'well well-small') +
      content_tag(:div, @nc.secondary_output.note_en.html_safe, class: 'well well-small')
    when @nc.is_a?(NomenclatureChange::StatusToSynonym)
      content_tag(:h1, "NomenclatureChange #{@nc.id} - STATUS TO SYNONYM", nil) +
      content_tag(:div, @nc.primary_output.internal_note.html_safe, class: 'well well-small')
    when @nc.is_a?(NomenclatureChange::StatusToAccepted)
      content_tag(:h1, "NomenclatureChange #{@nc.id} - STATUS TO ACCEPTED", nil) +
      content_tag(:div, @nc.primary_output.note_en.html_safe, class: 'well well-small')
    end
  end

  def generate_input_content
    if @nc.is_a?(NomenclatureChange::Lump)
      lump_inputs_tags + lump_inputs_content
    elsif @nc.input
      split_input_tag + split_input_content
    end
  end

  def generate_output_content
    if @nc.is_a?(NomenclatureChange::Lump)
      lump_output_tag + lump_output_content
    else
      outputs_tags + outputs_content
    end
  end

  def generate_tags(tc, idx)
    if idx == 0
      concat content_tag(:li, link_to("#{tc.full_name}",
        "##{tc.full_name.downcase.tr(' ', '_')}", "data-toggle" => "tab"), class: "active")
    else
      concat content_tag(:li, link_to("#{tc.full_name}",
        "##{tc.full_name.downcase.tr(' ', '_')}", "data-toggle" => "tab"))
    end
  end

  def lump_inputs_content
    content_tag(:div, class: 'tab-content') do
      @nc.inputs.each_with_index do |input, idx|
        tc = input.taxon_concept
        if idx == 0
          concat content_tag(:div, inner_content(input, tc),
            { id: "#{tc.full_name.downcase.tr(" ", "_")}", class: "tab-pane fade in active" })
        else
          concat content_tag(:div, inner_content(input, tc),
            { id: "#{tc.full_name.downcase.tr(" ", "_")}", class: "tab-pane fade" })
        end
      end
    end
  end

  def lump_inputs_tags
    content_tag(:ul, class: 'nav nav-tabs') do
      @nc.inputs.each_with_index do |input, idx|
        tc = input.taxon_concept
        generate_tags(tc, idx)
      end
    end
  end

  def lump_output_content
    tc = @nc.output.new_taxon_concept || @nc.output.taxon_concept
    content_tag(:div, class: 'tab-content') do
      content_tag(:div, inner_content(@nc.output, tc),
        { id: "output_#{tc.full_name.downcase.tr(" ", "_")}", class: 'tab-pane fade in active' })
    end
  end

  def lump_output_tag
    tc = @nc.output.new_taxon_concept || @nc.output.taxon_concept
    content_tag(:ul, class: 'nav nav-tabs') do
      content_tag(:li, class: 'active') do
        concat link_to("#{tc.full_name}",
          "#output_#{tc.full_name.downcase.tr(' ', '_')}")
      end
    end
  end

  def split_input_tag
    content_tag(:ul, class: 'nav nav-tabs') do
      content_tag(:li, class: 'active') do
        concat link_to("#{@nc.input.taxon_concept.full_name}",
          "#input_#{@nc.input.taxon_concept.full_name.downcase.tr(' ', '_')}")
      end
    end
  end

  def split_input_content
    content_tag(:div, class: 'tab-content') do
      content_tag(:div, inner_content(@nc.input, @nc.input.taxon_concept),
        { id: "input_#{@nc.input.taxon_concept.full_name.downcase.tr(" ", "_")}",
        class: 'tab-pane fade in active' })
    end
  end

  def outputs_tags
    outputs = Array.wrap(select_outputs)
    content_tag(:ul, class: 'nav nav-tabs') do
      outputs.each_with_index do |output, idx|
        tc = output.new_taxon_concept || output.taxon_concept
        generate_tags(tc, idx)
      end
    end
  end

  def outputs_content
    outputs = Array.wrap(select_outputs)
    content_tag(:div, class: 'tab-content') do
      outputs.each_with_index do |output, idx|
        tc = output.new_taxon_concept || output.taxon_concept
        if idx == 0
          concat content_tag(:div, inner_content(output, tc),
            { id: "#{tc.full_name.downcase.tr(" ", "_")}", class: "tab-pane fade in active" })
        else
          concat content_tag(:div, inner_content(output, tc),
            { id: "#{tc.full_name.downcase.tr(" ", "_")}", class: "tab-pane fade" })
        end
      end
    end
  end

  def inner_content(input_or_output, tc)
    is_output = input_or_output.is_a?(NomenclatureChange::Output)
    content_tag(:p, content_tag(:i, link_to(tc.full_name,
      admin_taxon_concept_names_path(tc)), nil)
    ) +
    if is_output
      content_tag(:p, "Name status: #{input_or_output.new_name_status || input_or_output.name_status}")
    end +
    content_tag(:p, "Author: #{tc.author_year || is_output && input_or_output.new_author_year}") +
    content_tag(:p, "Internal note: #{input_or_output.internal_note}")
  end

  def select_outputs
    if @nc.is_a?(NomenclatureChange::Split)
      @nc.outputs
    else
      [@nc.primary_output, @nc.secondary_output].compact
    end
  end

  def sorted_parent_reassignments(ff)
    ff.object.parent_reassignments.sort_by { |reassignment| reassignment.reassignable.full_name }
  end

  def name_reassignment_label(reassignment)
    taxon_relationship = reassignment.reassignable
    other_taxon_concept = taxon_relationship.other_taxon_concept
    content_tag(:label, class: 'control-label') do
      content_tag(:span, taxon_relationship.taxon_relationship_type.name) +
      tag(:br) +
      link_to(
        other_taxon_concept.full_name,
        admin_taxon_concept_names_path(other_taxon_concept)
      ) +
      content_tag(:span) do
        ' (' + (other_taxon_concept.name_status || '--') + ')'
      end +
      tag(:br) +
      content_tag(:span, other_taxon_concept.author_year).html_safe
    end
  end

  def select_taxonomy
    select("taxonomy", "taxonomy_id", Taxonomy.all.collect { |t| [t.name, t.id] })
  end

  def select_rank
    select("rank", "rank_id", ranks_collection)
  end

  def ranks_collection
    Rank.all.collect { |r| [r.name, r.id] }
  end

  def taxon_concepts_collection
    TaxonConcept.where(:taxonomy_id => 1).collect { |t| [t.full_name, t.id] }
  end

  def new_name_scientific_name_hint
    case @nomenclature_change.output.new_name_status
    when 'A' then "e.g. 'africana' for Loxodonta africana"
    when 'S', 'H' then "e.g. Loxodonta africana"
    end
  end
end
