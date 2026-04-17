class PagesController < ApplicationController
  layout 'pages'

  def about
  end

  def terms_of_use
  end

  def eu_legislation
    @eu_annex_regulations = EuRegulation.select(
      [
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]
    ).order(effective_at: :desc)

    @eu_suspension_regulations = EuSuspensionRegulation.select(
      [
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]
    ).order(effective_at: :desc)

    @eu_implementing_regulations = EuImplementingRegulation.select(
      [
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]
    ).order(effective_at: :desc)

    @eu_council_regulations = EuCouncilRegulation.select(
      [
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]
    ).order(effective_at: :desc)
  end

  def api
    @user = User.new(role: 'api')
  end
end
