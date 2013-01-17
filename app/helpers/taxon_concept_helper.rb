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
      link_to("Add new #{controller_name.titleize.singularize} synonym",
        "#new-#{controller_name.singularize}-synonym",
        :role => "button", :"data-toggle" => "modal",
        :class => "btn new-button"
      ) +
      link_to("Add new #{controller_name.titleize.singularize}",
        "#new-#{controller_name.singularize}",
        :role => "button", :"data-toggle" => "modal",
        :class => "btn new-button"
      )
    end
  end

  def admin_new_modal
    content_tag(
      :div,
      :id => "new-#{controller_name.singularize}-synonym",
      :class => "modal hide fade", :tabindex => "-1", :role => "dialog",
      :"aria-labelledby" => "new-#{controller_name.singularize}-synonym-label",
      :"aria-hidden" => "true") do

      content_tag(:div, :class => "modal-header") do
        button_tag(
          :type => "button", :class => "close", :"data-dismiss" => "modal",
          :"aria-hidden" => true
        ){'×'} +
        content_tag(:h3, 
          :id => "new-#{controller_name.singularize}-synonym-label"
        ){"Add new #{controller_name.titleize.singularize} synonym"}
      end +
      content_tag(
        :div, :id => "admin-new-record-form", :class => "modal-body"
      ) do
        if block_given?
          yield
        else
          render :partial => 'synonym_form'
        end
      end +
      content_tag(:div, :class => "modal-footer") do
        button_tag(
          :type => "button", :class => "btn", :"data-dismiss" => "modal",
          :"aria-hidden" => "true"
        ){'Close'} +
        button_tag(
          :type => "button", :class => "btn btn-primary save-button"
        ){'Save changes'}
      end
    end
  end
end
