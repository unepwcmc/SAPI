class Admin::ChangeTypesController < Admin::StandardAuthorizationController
protected

  def collection
    @change_types ||= end_of_association_chain.includes(
      :designation
    ).order(
      'designation_id, name'
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

  def load_associations
    @designations = Designation.order(:name)
  end

private

  def change_type_params
    params.expect(
      change_type: [
        :name, :designation_id,
        :display_name_en, :display_name_es, :display_name_fr
      ]
    )
  end
end
