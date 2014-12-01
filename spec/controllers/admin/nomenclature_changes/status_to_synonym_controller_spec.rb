require 'spec_helper'

describe Admin::NomenclatureChanges::StatusToSynonymController do
  login_admin
  include_context 'status_change_definitions'

  describe 'GET show' do
    context :primary_output do
      before(:each) do
        @status_change = create(:nomenclature_change_status_to_synonym)
      end
      it 'renders the primary_output template' do
        get :show, id: :primary_output, nomenclature_change_id: @status_change.id
        response.should render_template('primary_output')
      end
    end
    context :relay do
      before(:each) do
        @status_change = a_to_s_with_primary_output
      end
      it 'renders the relay template' do
        get :show, id: :relay, nomenclature_change_id: @status_change.id
        response.should render_template('relay')
      end
    end
    context :notes do
      before(:each) do
        @status_change = a_to_s_with_primary_output
      end
      it 'renders the notes template' do
        get :show, id: :notes, nomenclature_change_id: @status_change.id
        response.should render_template('notes')
      end
    end
    context :reassignments do
      before(:each) do
        @status_change = a_to_s_with_input_and_secondary_output
      end
      context "when legislation present" do
        before(:each) do
          create_cites_I_addition(taxon_concept: input_species)
        end
        it 'renders the legislation template' do
          get :show, id: :legislation, nomenclature_change_id: @status_change.id
          response.should render_template('legislation')
        end
      end
      context "when no legislation" do
        it 'redirects to next step' do
          get :show, id: :legislation, nomenclature_change_id: @status_change.id
          response.should redirect_to(admin_nomenclature_change_status_to_synonym_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'summary'
          ))
        end
      end
    end
    context :summary do
      before(:each) do
        @status_change = a_to_s_with_input_and_secondary_output
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
      response.should redirect_to(admin_nomenclature_change_status_to_synonym_url(
        nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'primary_output'
      ))
    end
  end

  describe 'PUT update' do
    before(:each) do
      @status_change = create(:nomenclature_change_status_to_synonym)
    end
    context 'when successful' do
      it 'redirects to next step' do
        put :update, nomenclature_change_status_to_synonym: {
          primary_output_attributes: {
            taxon_concept_id: create_cites_eu_species.id,
            new_name_status: 'S'
          }
        }, nomenclature_change_id: @status_change.id, id: 'primary_output'
        response.should redirect_to(admin_nomenclature_change_status_to_synonym_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'relay'
        ))
      end
    end
    context 'when unsuccessful' do
      it 're-renders step' do
        put :update, nomenclature_change_status_to_synonym: {},
          nomenclature_change_id: @status_change.id, id: 'primary_output'
        response.should render_template('primary_output')
      end
    end
  end

end
