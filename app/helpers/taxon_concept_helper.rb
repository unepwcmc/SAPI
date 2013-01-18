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
      )
      admin_add_new_synonym_button +
      admin_add_new_button
    end
  end

  def admin_add_new_synonym_button
    admin_add_new_button(
      :resource => 'taxon_concept_synonym'
    )
  end

  def admin_new_synonym_modal
    admin_new_modal(
      :resource => 'taxon_concept_synonym'
    ){ render 'synonym_form' }
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
