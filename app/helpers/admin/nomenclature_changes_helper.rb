module Admin::NomenclatureChangesHelper

  def nomenclature_change_form(submit_label = 'Next', &block)
    nested_form_for @nomenclature_change, url: wizard_path, method: :put,
      html: {class: 'form-horizontal'} do |f|
      html = error_messages_for(@nomenclature_change)
      html += capture { block.yield(f) } if block_given?
      html += content_tag(:div, class: 'clearfix') do
        concat link_to('Cancel', admin_nomenclature_changes_path,
          class: 'pull-left btn btn-link')
        concat ' '
        concat f.submit(submit_label, class: 'pull-right btn btn-primary')
        concat ' '
        concat link_to('Previous ', previous_wizard_path,
          class: 'pull-right btn btn-link')
      end
      html += progress_bar
      html.html_safe
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
      unless @nomenclature_change.outputs.empty?
        concat ' into '
        total = @nomenclature_change.outputs.size
        @nomenclature_change.outputs.each_with_index do |output, idx|
          if output.taxon_concept && !output.new_full_name
            concat link_to(
              output.taxon_concept.full_name,
              admin_taxon_concept_names_path(output.taxon_concept)
            )
          else
            concat output.display_full_name
          end
          concat ', ' if idx < (total - 1)
        end
      end
    end
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
      if @nomenclature_change.output
        concat ' into '
        if @nomenclature_change.output.taxon_concept && !@nomenclature_change.output.new_full_name
          concat link_to(
            @nomenclature_change.output.taxon_concept.full_name,
            admin_taxon_concept_names_path(@nomenclature_change.output.taxon_concept)
          )
        else
          concat @nomenclature_change.output.display_full_name
        end
      end
    end
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
      if @nomenclature_change.is_swap?
        concat ' (status swap with '
        concat link_to(
          @nomenclature_change.secondary_output.taxon_concept.full_name,
          admin_taxon_concept_names_path(@nomenclature_change.secondary_output.taxon_concept)
        )
        concat ')'
      end
    end
  end

end
