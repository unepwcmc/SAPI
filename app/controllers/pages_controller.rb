class PagesController < ApplicationController
  layout 'pages'
  
  def about
  end

  def terms_of_use
  end

  def eu_legislation
    @eu_annex_regulations = EuRegulation.
      select([:description, :effective_at, :url, :is_current]).
      order('effective_at DESC')
    @eu_suspension_regulations = EuSuspensionRegulation.
      select([:description, :effective_at, :url, :is_current]).
      order('effective_at DESC')
  end
end