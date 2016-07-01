class Api::V1::TermsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
    { :locale => "en" }.merge(c.params.select { |k, v| !v.blank? && "locale" == k })
  }
  def index
    @terms = Term.all(:order => "code")
    render :json => @terms,
      :each_serializer => Species::TermSerializer,
      :meta => { :total => @terms.count }
  end
end
