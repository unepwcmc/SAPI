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
      ) +
      admin_add_new_hybrid_button +
      admin_add_new_synonym_button +
      admin_add_new_button
    end
  end

  def admin_add_new_synonym_button(nested = false)
    if nested
      admin_add_new_button(
        :resource => 'taxon_concept_synonym',
        :href => new_admin_taxon_concept_synonym_relationship_url(@taxon_concept),
        :remote => true,
        :"data-toggle" => nil,
        :role => nil
      )
    else
      admin_add_new_button(
        :resource => 'taxon_concept_synonym',
        :name => 'Add new synonym'
      )
    end
  end

  def admin_add_new_hybrid_button(nested = false)
    if nested
      admin_add_new_button(
        :resource => 'taxon_concept_hybrid',
        :href => new_admin_taxon_concept_hybrid_relationship_url(@taxon_concept),
        :remote => true,
        :"data-toggle" => nil,
        :role => nil
      )
    else
      admin_add_new_button(
        :resource => 'taxon_concept_hybrid'
      )
    end
  end

  def admin_new_synonym_modal(nested = false)
    admin_new_modal(
      :resource => 'taxon_concept_synonym',
    ){ nested ? '' : render('synonym_form') }
  end

  def admin_add_new_distribution_button(nested = false)
    admin_add_new_button(
      :resource => 'distributions',
      :name => 'Add new distribution location'
    )
  end

  def admin_new_distribution_modal()
    admin_new_modal(
      :resource => 'distributions',
      :title => 'Add new distribution location'
    ){ render 'admin/distributions/form' }
  end

  def admin_new_hybrid_modal(nested = false)
    admin_new_modal(
      :resource => 'taxon_concept_hybrid'
    ){ nested ? '' : render('hybrid_form') }
  end

  def admin_new_taxon_concept_modal
    admin_new_modal(
      :resource => 'taxon_concept'
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
      :resource => 'common_name'
    ){ '' }
  end
end
