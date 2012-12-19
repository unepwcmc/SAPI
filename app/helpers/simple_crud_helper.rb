#encoding: utf-8
module SimpleCrudHelper
  def error_messages_for(resource)
    resource = instance_variable_get("@#{resource}") if resource.is_a? Symbol
    return '' unless resource && resource.errors.any?
    content_tag(:div, :class => 'alert alert-error') do
      link_to('×', '#', :"data-dismiss" => 'alert', :class => 'close') +
      content_tag(
        :p,
        "#{pluralize(resource.errors.count, "error")} prohibited this designation from being saved:"
      ) +
      content_tag(:ul) do
        resource.errors.full_messages.collect {|item| concat(content_tag(:li, item))}
      end
    end
  end
end