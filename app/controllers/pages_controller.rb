class PagesController < ApplicationController
  layout 'pages'

  def about
  end

  def terms_of_use
  end

  def eu_legislation
    @eu_annex_regulations = EuRegulation.
      select([
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]).
      order('effective_at DESC')
    @eu_suspension_regulations = EuSuspensionRegulation.
      select([
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]).
      order('effective_at DESC')
    @eu_implementing_regulations = EuImplementingRegulation.
      select([
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]).
      order('effective_at DESC')
    @eu_council_regulations = EuCouncilRegulation.
      select([
        :id, :description, :extended_description, :effective_at,
        :multilingual_url, :is_current
      ]).
      order('effective_at DESC')
  end

  def api
    @user = User.new(role: 'api')
  end
end
