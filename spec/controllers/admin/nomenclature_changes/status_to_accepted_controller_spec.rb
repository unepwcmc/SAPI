require 'spec_helper'

describe Admin::NomenclatureChanges::StatusToAcceptedController do
  login_admin
  include_context 'status_change_definitions'

  describe 'GET show' do
    context 'primary_output' do
      before(:each) do
        @status_change = create(:nomenclature_change_status_to_accepted)
      end
      it 'renders the primary_output template' do
        get :show, id: :primary_output, nomenclature_change_id: @status_change.id
        response.should render_template('primary_output')
      end
    end
    context 'summary' do
      before(:each) do
        @status_change = t_to_a_with_input
      end
      it 'renders the summary template' do
        get :show, id: :summary, nomenclature_change_id: @status_change.id
        response.should render_template('summary')
      end
    end
  end

  describe 'POST create' do
    it 'redirects to status_change wizard' do
      post :create, nomenclature_change_id: 'new'
      response.should redirect_to(
        admin_nomenclature_change_status_to_accepted_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'primary_output'
        )
      )
    end
  end

  describe 'PUT update' do
    before(:each) do
      @status_change = create(:nomenclature_change_status_to_accepted)
    end
    context 'when successful' do
      it 'redirects to next step' do
        put :update, nomenclature_change_status_to_accepted: {
          primary_output_attributes: {
            taxon_concept_id: create_cites_eu_species(
              name_status: 'T',
              taxon_name: create(:taxon_name, scientific_name: 'Patagonus miserabilis')
            ).id,
            new_parent_id: create_cites_eu_genus(
              taxon_name: create(:taxon_name, scientific_name: 'Patagonus')
            ).id,
            new_name_status: 'A'
          }
        }, nomenclature_change_id: @status_change.id, id: 'primary_output'
        response.should redirect_to(
          admin_nomenclature_change_status_to_accepted_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'summary'
          )
        )
      end
    end
    context 'when unsuccessful' do
      it 're-renders step' do
        put :update, nomenclature_change_status_to_accepted: {},
          nomenclature_change_id: @status_change.id, id: 'primary_output'
        response.should render_template('primary_output')
      end
    end
    context 'when last step' do
      context 'when user is secretariat' do
        login_secretariat_user
        it 'redirects to admin root path' do
          put :update, nomenclature_change_id: @status_change.id, id: 'summary'
          response.should redirect_to admin_root_path
        end
      end
      context 'when user is manager' do
        it 'redirects to nomenclature changes path' do
          pending("Strange render mismatch after upgrading to Rails 4")
          put :update, nomenclature_change_id: @status_change.id, id: 'summary'
          response.should be_successful
          response.should render_template("nomenclature_changes")
        end
      end
    end
  end

end
