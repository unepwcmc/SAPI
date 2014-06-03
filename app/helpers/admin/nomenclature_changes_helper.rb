module Admin::NomenclatureChangesHelper

  def nomenclature_change_form(submit_label = 'Next', &block)
    nested_form_for @nomenclature_change, url: wizard_path, method: :put,
      html: {class: 'form-horizontal'} do |f|
      html = error_messages_for(@nomenclature_change)
      html += capture { block.yield(f) } if block_given?
      html += content_tag(:div, class: 'control-group') do
        content_tag(:div, class: 'controls') do
          concat render('admin/nomenclature_changes/build/cancel_button')
          concat ' '
          concat f.submit(submit_label)
        end
      end
      html.html_safe
    end
  end

end
