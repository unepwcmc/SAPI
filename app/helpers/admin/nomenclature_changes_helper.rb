module Admin::NomenclatureChangesHelper

  def nomenclature_change_form(submit_label = 'Next', &block)
    nested_form_for @nomenclature_change, url: wizard_path, method: :put,
      html: {class: 'form-horizontal'} do |f|
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

  def print_summary summary
    if summary.kind_of?(Array)
      content_tag(:ul) do
        summary.each{ |line| concat print_summary(line) }
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
    html = content_tag(:p, content_tag(:i, nil, class: "icon-info-sign") + " Global selection")
    @nomenclature_change.outputs.map do |output|
      html += content_tag(:div, class: 'species-checkbox') do
        tag("input", {type: "checkbox", class: 'select-partial-checkbox', checked: checked}) +
        content_tag(:span, output.display_full_name, class: 'species-name')
      end
    end
    html.html_safe
  end

  def outputs_selection ff
    content_tag(:div, class: 'outputs_selection') do
      [ 'New taxon', 'Upgraded taxon', 'Existing taxon'].each do |opt|
        concat content_tag(:span,
          radio_button_tag(ff.object.taxon_concept.try(:full_name) || 'output'+ff.object.id.to_s,
          opt, false, class: 'output-radio') + ' ' + opt)
      end
      concat ff.link_to_remove 'Remove output'
    end
  end

end
