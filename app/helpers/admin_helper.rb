module AdminHelper

  def ancestors_path(taxon_concept)
    Rank.where(
      ["taxonomic_position < ?", taxon_concept.rank.taxonomic_position]
      ).order(:taxonomic_position).map do |r|
      return nil unless taxon_concept.data
      name = taxon_concept.data["#{r.name.downcase}_name"]
      id = taxon_concept.data["#{r.name.downcase}_id"]
      if name && id
        link_to(name, params.merge(:taxon_concept_id => id), :title => r.name)
      else
        nil
      end
    end.compact.join(' > ').html_safe
  end

  def tracking_info(record)
    info = <<-HTML
      <p>Created by #{record.creator.try(:name) || "DATA_IMPORT"} on
        #{record.created_at.strftime("%d/%m/%Y")}<br />
        Last updated by #{record.updater.try(:name) || "DATA_IMPORT"} on
        #{record.updated_at.strftime("%d/%m/%Y")}
      </p>
    HTML
    content_tag(:a, :rel => 'tooltip', :href => '#',
      :"data-original-title" => info, :"data-html" => true
    ) do
      info_icon
    end.html_safe
  end

  def internal_notes(record)
    return '' unless record.internal_notes.present?
    info = content_tag(:div) do
      content_tag(:b, 'Internal notes:') +
      content_tag(:p, record.internal_notes)
    end
    comment_icon_with_tooltip(info)
  end

  def comment_icon_with_tooltip(tooltip_text)
    content_tag(
      :a, rel: 'tooltip', href: '#',
      'data-original-title' => tooltip_text,
      'data-html' => true
    ) do
      comment_icon
    end
  end

  def comment_icon
    '<i class="icon-comment" title="Internal notes"></i>'.html_safe
  end

  def info_icon
    '<i class="icon-info-sign" title="Info"></i>'.html_safe
  end

  def edit_icon
    '<i class="icon-pencil" title="Edit"></i>'.html_safe
  end

  def delete_icon
    '<i class="icon-trash" title="Delete"></i>'.html_safe
  end

  def true_false_icon(bool_value)
    bool_value ? '<i class="icon-ok"></i>'.html_safe : ''
  end

  def tag_list(tags_ary)
    tags_ary.map { |t| content_tag(:span, :class => 'myMinTag') { t } }.join(', ').html_safe
  end

  def error_messages_for(resource)
    resource = instance_variable_get("@#{resource}") if resource.is_a? Symbol
    return '' unless resource && resource.errors.any?
    content_tag(:div, :class => 'alert alert-error') do
      link_to('×', '#', :"data-dismiss" => 'alert', :class => 'close') +
      content_tag(
        :p,
        "#{pluralize(resource.errors.count, "error")} " +
        "prohibited this record from being saved:"
      ) +
      content_tag(:ul) do
        resource.errors.full_messages.collect do |item|
          concat(content_tag(:li, item))
        end
      end
    end
  end

  def admin_title
    content_tag(:div, :class => 'admin-header') do
      content_tag(:h1,
        if block_given?
          yield
        elsif @custom_title
          @custom_title
        else
          controller_name.titleize
        end
      ) + content_tag(:div, :class => 'action-buttons') do
        admin_add_new_button :custom_btn_title => @custom_btn_title
      end
    end
  end

  def admin_add_new_button(options = {})
    resource = options[:resource] || controller_name.singularize
    href = options.delete(:href) || "#new-#{resource}"
    name = options.delete(:name) || options[:custom_btn_title] || "Add new #{resource.titleize}"
    link_to('<i class="icon-plus-sign"></i> '.html_safe + name, href,
      {
        :role => "button",
        :"data-toggle" => "modal",
        :class => "btn new-button"
      }.merge(options)
    )
  end

  def admin_new_modal(options = {})
    resource = options[:resource] || controller_name.singularize
    id = options[:id] || "new-#{resource}"
    title = options[:title] || "Add new #{resource.titleize}"
    content_tag(
      :div,
      :id => id,
      :class => "modal hide fade", :tabindex => "-1", :role => "dialog",
      :"aria-labelledby" => "#{id}-label",
      :"aria-hidden" => "true") do

      content_tag(:div, :class => "modal-header") do
        button_tag(
          :type => "button", :class => "close", :"data-dismiss" => "modal",
          :"aria-hidden" => true
        ) { '×' } +
        content_tag(:h3,
          :id => "#{id}-label"
        ) { title }
      end +
      content_tag(
        :div, :id => "admin-#{id}-form", :class => "modal-body" # TODO
      ) do
        if block_given?
          yield
        else
          render :partial => 'form'
        end
      end +
      content_tag(:div, :class => "modal-footer") do
        button_tag(
          :type => "button", :class => "btn", :"data-dismiss" => "modal",
          :"aria-hidden" => "true"
        ) { 'Close' } +
        if options[:save_and_reopen]
          button_tag(
            :type => "button", :class => "btn btn-primary save-button save-and-reopen-button"
          ) { 'Save changes' } +
          button_tag(
            :type => "button", :class => "btn btn-primary save-button"
          ) { 'Save changes & close' }
        else
          button_tag(
            :type => "button", :class => "btn btn-primary save-button"
          ) { 'Save changes' }
        end
      end
    end
  end

  def admin_table
    content_tag(
      :table, :id => "admin-in-place-editor",
      :class => "table table-bordered table-striped ",
      :"data-editor-for" => "#{controller_name.singularize}",
      :style => "clear: both"
    ) do
      if block_given?
        yield
      else
        render partial: 'list'
      end
    end
  end

  def admin_simple_search
    content_tag(
      :div, :id => "admin-simple-search",
      :class => "simple-search",
      :style => "clear: both"
    ) do
      render :partial => 'admin/simple_crud/simple_search'
    end
  end

end
