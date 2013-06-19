#encoding: utf-8
module TaxonConceptHelper
  def admin_taxon_concept_title
    content_tag(:div, :class => 'admin-header') do
      content_tag(:h1,
        if block_given?
          yield
        else
          controller_name.titleize
        end
      ) + (content_tag(:div, :class => 'action-buttons') do
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
        end
      end
    end
  end

  def admin_add_new_synonym_button
    admin_add_new_button(
      :resource => 'taxon_concept_synonym',
      :href => new_admin_taxon_concept_synonym_relationship_url(@taxon_concept),
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_add_new_hybrid_button
    admin_add_new_button(
      :resource => 'taxon_concept_hybrid',
      :href => new_admin_taxon_concept_hybrid_relationship_url(@taxon_concept),
      :remote => true,
      :"data-toggle" => nil,
      :role => nil
    )
  end

  def admin_new_synonym_modal(nested = false)
    admin_new_modal(
      :resource => 'taxon_concept_synonym',
    ){ nested ? '' : render('synonym_form') }
  end

  def admin_add_new_distribution_button
    admin_add_new_button(
      :resource => 'distributions',
      :href => new_admin_taxon_concept_distribution_url(@taxon_concept),
      :name => 'Add new distribution location',
      :remote => true,
      :'data-toggle' => nil,
      :role => nil
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

  def admin_new_distribution_modal( nested = false)
    admin_new_modal(
      :resource => 'distribution'
    ){ nested ? '' : render('admin/distributions/form') }
  end

  def admin_edit_distribution_modal(nested = false)
    admin_new_modal(
      :resource => 'distribution',
      :id => 'edit-distribution',
      :title => 'Edit Distribution'
    ){ nested ? '' : render('admin/distributions/form') }
  end

  def admin_new_hybrid_modal(nested = false)
    admin_new_modal(
      :resource => 'taxon_concept_hybrid'
    ){ nested ? '' : render('hybrid_form') }
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

  def admin_new_taxon_concept_modal
    admin_new_modal(
      :resource => 'taxon_concept'
    ){ '' }
  end

  def admin_new_cites_suspension_modal
    admin_new_modal(
      :resource => 'cites_suspension'
    ){ '' }
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
    ){ '' }
  end
end
