module Admin::TradeCodesHelper
  def sub_nav
    content_tag(:ul, :class => "nav nav-pills") do
      ["purposes", "sources", "terms", "units"].each do |subclass|
        concat(content_tag(:li, :class => "#{controller_name == subclass ? 'active' : ''}") do
          link_to subclass.titleize, send("admin_#{subclass}_path")
        end)
      end
    end
  end
end
