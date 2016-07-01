module TaxonConceptHelper
  def admin_taxon_concept_title
    content_tag(:div, :class => 'admin-header') do
      content_tag(:h1,
        if block_given?
          yield
        else
          controller_name.titleize
        end
      ) + (content_tag(:div, class: 'action-buttons') do
        admin_add_new_taxon_concept_multi
      end)
    end
  end

  def admin_add_new_taxon_concept_multi
    content_tag(:div, :class => 'btn-group', :style => 'float:right') do
      link_to('<i class="icon-plus-sign"></i> Add new Taxon Concept'.html_safe, '#', :class => 'btn') +
      link_to('<span class="caret"></span>'.html_safe, '#', :class => 'btn dropdown-toggle', :"data-toggle" => 'dropdown') +
      content_tag(:ul, :class => 'dropdown-menu') do
        content_tag(:li) do
          link_to('Accepted name', '#new-taxon_concept', :"data-toggle" => 'modal')
        end +
        content_tag(:li) do
          link_to('Synonym', '#new-taxon_concept_synonym', :"data-toggle" => 'modal')
        end +
        content_tag(:li) do
          link_to('Hybrid', '#new-taxon_concept_hybrid', :"data-toggle" => 'modal')
        end +
        content_tag(:li) do
          link_to('N name', '#new-taxon_concept_n_name', :"data-toggle" => 'modal')
        end
      end
    end
  end

  def admin_add_new_synonym_button
    admin_add_new_button(
      :resource => 'taxon_concept_synonym',
      :href => new_admin_taxon_concept_synonym_relationship_url(@taxon_concept),
      :name => 'Add new Synonym',
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_add_new_trade_name_button
    admin_add_new_button(
      :resource => 'taxon_concept_trade_name',
      :href => new_admin_taxon_concept_trade_name_relationship_url(@taxon_concept),
      :name => 'Add new Trade name',
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_add_new_hybrid_button
    admin_add_new_button(
      :resource => 'taxon_concept_hybrid',
      :href => new_admin_taxon_concept_hybrid_relationship_url(@taxon_concept),
      :name => 'Add new Hybrid',
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_new_synonym_modal(options = {})
    nested = options[:nested] || false
    admin_new_modal(
      resource: 'taxon_concept_synonym',
      title: options[:title] || nil
    ) { nested ? '' : render('synonym_form') }
  end

  def admin_new_trade_name_modal(options = {})
    nested = options[:nested] || false
    admin_new_modal(
      resource: 'taxon_concept_trade_name',
      title: options[:title] || nil
    ) { nested ? '' : render('trade_name_form') }
  end

  def admin_new_hybrid_modal(options = {})
    nested = options[:nested] || false
    admin_new_modal(
      resource: 'taxon_concept_hybrid',
      title: options[:title] || nil
    ) { nested ? '' : render('hybrid_form') }
  end

  def admin_new_n_name_modal(options = {})
    nested = options[:nested] || false
    admin_new_modal(
      resource: 'taxon_concept_n_name',
      title: options[:title] || nil
    ) { nested ? '' : render('n_name_form') }
  end

  def admin_new_taxon_concept_modal(options = {})
    nested = options[:nested] || false
    admin_new_modal(
      resource: 'taxon_concept',
      title: options[:title] || nil
    ) { nested ? '' : render('form') }
  end

  def admin_add_new_distribution_button
    admin_add_new_button(
      resource: 'distributions',
      href: new_admin_taxon_concept_distribution_url(@taxon_concept),
      name: 'Add new distribution location',
      remote: true,
      'data-toggle' => nil,
      role: nil,
      class: 'btn new-button pull-right'
    )
  end

  def admin_add_new_cites_suspension_button
    admin_add_new_button(
      :resource => 'cites_suspensions',
      :href => new_admin_cites_suspension_url,
      :name => 'Add suspension',
      :remote => true,
      :'data-toggle' => nil,
      :role => nil
    )
  end

  def admin_new_distribution_modal(nested = false)
    admin_new_modal(
      :resource => 'distribution'
    ) { nested ? '' : render('admin/distributions/form') }
  end

  def admin_edit_distribution_modal(nested = false)
    admin_new_modal(
      :resource => 'distribution',
      :id => 'edit-distribution',
      :title => 'Edit Distribution'
    ) { nested ? '' : render('admin/distributions/form') }
  end

  def admin_add_new_reference_button
    admin_add_new_button(
      :resource => 'taxon_concept_reference',
      :href => new_admin_taxon_concept_taxon_concept_reference_url(@taxon_concept),
      :name => 'Add new reference',
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_new_reference_modal(nested = false)
    admin_new_modal(
      :resource => 'taxon_concept_reference',
      :save_and_reopen => true
    )
  end

  def admin_new_cites_suspension_modal
    admin_new_modal(
      :resource => 'cites_suspension'
    ) { '' }
  end

  def admin_add_new_common_name_button
    admin_add_new_button(
      :resource => 'common_name',
      :href => new_admin_taxon_concept_taxon_common_url(@taxon_concept),
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_new_common_name_modal
    admin_new_modal(
      :resource => 'common_name', :save_and_reopen => true
    ) { '' }
  end

  def excluded_taxon_concepts_tooltip(obj)
    obj.excluded_taxon_concepts.
      map(&:full_name).join(', ')
  end

  def taxon_concept_internal_notes_popover_link
    content_tag(
      :span, rel: 'popover', href: '#',
      'data-original-title' => 'Internal notes',
      'data-html' => true,
      'data-trigger' => 'hover',
      'data-placement' => 'left',
      id: 'taxon_concept_internal_notes_popover_link'
    ) do
      comment_icon
    end
  end

  def taxon_concept_internal_note_label(comment)
    content_tag(:label) do
      content_tag(:p, class: 'internal-notes-type') do
        comment.comment_type + ' note'
      end +
      content_tag(:div, class: 'internal-notes-meta') do
        updater = comment.try(:updater)
        if updater
          "Last updated by #{updater.try(:name)}"
        else
          ''
        end
      end +
      content_tag(:div, class: 'internal-notes-meta') do
        updated_at = comment.try(:updated_at).try(:strftime, "%d/%m/%y %H:%M")
        if updated_at
          "at #{updated_at}"
        else
          ''
        end
      end
    end
  end

  def taxon_concept_internal_note_form(comment)
    form_for [:admin, @taxon_concept, comment] do |f|
      content_tag(:table, style: 'width:100%') do
        content_tag(:tr) do
          content_tag(:td, style: 'width:30%') do
            taxon_concept_internal_note_label(comment)
          end +
          content_tag(:td) do
            f.text_area(
              :note,
              rows: 4,
              style: 'width:100%'
            ) +
            f.hidden_field(:comment_type) +
            f.submit('Update', class: 'btn btn-primary')
          end
        end
      end
    end
  end

  def taxon_concept_internal_note_display(comment)
    return '' unless comment
    content_tag(:table, style: 'width:100%') do
      content_tag(:tr) do
        content_tag(:td, style: 'width:30%') do
          taxon_concept_internal_note_label(comment)
        end +
        content_tag(:td, comment.note)
      end
    end
  end

  def taxon_concept_internal_note_tab_display(comment)
    if comment && comment.note.present?
      content_tag(:div, { class: 'alert alert-info' }) do
        taxon_concept_internal_note_display(comment)
      end
    end
  end
end
