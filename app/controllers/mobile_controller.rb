class MobileController < ApplicationController
  layout 'mobile'

  def terms_and_conditions
    @hero = t('mobile.terms.hero')
    @body = t('mobile.terms.body')
    render 'shared/_mobile'
  end

  def privacy_policy
    @hero = t('mobile.privacy.hero')
    @body = t('mobile.privacy.body')
    render 'shared/_mobile'
  end
end
