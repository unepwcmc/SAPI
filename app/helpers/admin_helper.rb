#encoding: utf-8
module AdminHelper
  def edit_icon
    '<i class="icon-pencil"></i>'.html_safe
  end

  def delete_icon
    '<i class="icon-trash"></i>'.html_safe
  end

  def true_false_icon(bool_value)
    bool_value ? '<i class="icon-ok"></i>'.html_safe : ''
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
        else
          controller_name.titleize
        end
      ) + content_tag(:div, :class => 'action-buttons') do
        admin_add_new_button
      end
    end
  end

  def admin_add_new_button(options = {})
    resource = options[:resource] || controller_name.singularize
    href = options.delete(:href) || "#new-#{resource}"
    name = options.delete(:name) || "Add new #{resource.titleize}"
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
        ){'×'} +
        content_tag(:h3, 
          :id => "#{id}-label"
        ){title}
      end +
      content_tag(
        :div, :id => "admin-new-#{resource}-form", :class => "modal-body" #TODO
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
        ){'Close'} +
        button_tag(
          :type => "button", :class => "btn btn-primary save-button"
        ){'Save changes'}
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
        render :partial => 'list', :locals => {:collection => collection}
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
