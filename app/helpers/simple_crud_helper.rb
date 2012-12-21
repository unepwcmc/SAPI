#encoding: utf-8
module SimpleCrudHelper
  def error_messages_for(resource)
    resource = instance_variable_get("@#{resource}") if resource.is_a? Symbol
    return '' unless resource && resource.errors.any?
    content_tag(:div, :class => 'alert alert-error') do
      link_to('×', '#', :"data-dismiss" => 'alert', :class => 'close') +
      content_tag(
        :p,
        "#{pluralize(resource.errors.count, "error")} " +
        "prohibited this designation from being saved:"
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
      :id => "new-#{controller_name.singularize}",
      :class => "modal hide fade", :tabindex => "-1", :role => "dialog",
      :"aria-labelledby" => "new-#{controller_name.singularize}-label",
      :"aria-hidden" => "true") do

      content_tag(:div, :class => "modal-header") do
        button_tag(
          :type => "button", :class => "close", :"data-dismiss" => "modal",
          :"aria-hidden" => true
        ){'×'} +
        content_tag(:h3, 
          :id => "new-#{controller_name.singularize}-label"
        ){"Add new #{controller_name.titleize.singularize}"}
      end +
      content_tag(
        :div, :id => "admin-new-record-form", :class => "modal-body"
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
      :class => "table table-bordered table-striped " +
        "#{collection.class}-editor",
      :style => "clear: both"
    ) do
      if block_given?
        yield
      else
        render :partial => 'list', :locals => {:collection => collection}
      end
    end
  end

end