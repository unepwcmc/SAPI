class Api::V1::DocumentTagsController < ApplicationController

  def index
    @document_tags = DocumentTag.
      select([:id, :name, :type]).
      order([:type, :name])
    render :json => @document_tags,
      :each_serializer => Species::DocumentTagSerializer,
      :meta => {:total => @document_tags.count}
  end

end
