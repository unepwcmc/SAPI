require 'spec_helper'

describe Admin::NomenclatureChanges::LumpController do
  login_admin

  describe 'GET show' do
    context 'inputs' do
      before(:each) do
        @lump = create(:nomenclature_change_lump)
      end
      it 'renders the inputs template' do
        get :show, id: :inputs, nomenclature_change_id: @lump.id
        response.should render_template('inputs')
      end
    end
    context 'outputs' do
      before(:each) do
        @lump = create(:nomenclature_change_lump)
        create(:nomenclature_change_input, nomenclature_change: @lump)
      end
      it 'renders the outputs template' do
        get :show, id: :outputs, nomenclature_change_id: @lump.id
        response.should render_template('outputs')
      end
    end
    context 'reassignments' do
      before(:each) do
        @input_species = create_cites_eu_species
        @lump = create(:nomenclature_change_lump)
        create(:nomenclature_change_input, nomenclature_change: @lump, taxon_concept: @input_species)
        create(:nomenclature_change_output, nomenclature_change: @lump)
      end
      it 'renders the notes template' do
        get :show, id: :notes, nomenclature_change_id: @lump.id
        response.should render_template('notes')
      end
      context "when legislation present" do
        before(:each) do
          create_cites_I_addition(taxon_concept: @input_species)
        end
        it 'renders the legislation template' do
          get :show, id: :legislation, nomenclature_change_id: @lump.id
          response.should render_template('legislation')
        end
      end
      context "when no legislation" do
        it 'redirects to next step' do
          get :show, id: :legislation, nomenclature_change_id: @lump.id
          response.should redirect_to(
            admin_nomenclature_change_lump_url(
              nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'summary'
            )
          )
        end
      end
      it 'renders the summary template' do
        get :show, id: :summary, nomenclature_change_id: @lump.id
        response.should render_template('summary')
      end
    end
  end

  describe 'POST create' do
    it 'redirects to lump wizard' do
      post :create, nomenclature_change_id: 'new'
      response.should redirect_to(
        admin_nomenclature_change_lump_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'inputs'
        )
      )
    end
  end

  describe 'PUT update' do
    before(:each) do
      @lump = create(:nomenclature_change_lump)
    end
    context 'when successful' do
      it 'redirects to next step' do
        put :update, nomenclature_change_lump: {
          inputs_attributes: {
            0 => { taxon_concept_id: create_cites_eu_species.id },
            1 => { taxon_concept_id: create_cites_eu_species.id }
          }
        }, nomenclature_change_id: @lump.id, id: 'inputs'
        response.should redirect_to(
          admin_nomenclature_change_lump_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'outputs'
          )
        )
      end
    end
    context 'when unsuccessful' do
      it 're-renders step' do
        put :update,
          nomenclature_change_lump: {
            inputs_attributes: {
              0 => { taxon_concept_id: nil }
            }
          }, nomenclature_change_id: @lump.id, id: 'inputs'
        response.should render_template('inputs')
      end
    end
    context 'when last step' do
      context 'when user is secretariat' do
        login_secretariat_user
        it 'redirects to admin root path' do
          put :update, nomenclature_change_id: @lump.id, id: 'summary'
          response.should redirect_to admin_root_path
        end
      end
      context 'when user is manager' do
        it 'redirects to nomenclature changes path' do
          pending("Strange render mismatch after upgrading to Rails 4")
          put :update, nomenclature_change_id: @lump.id, id: 'summary'
          response.should be_successful
          response.should render_template("nomenclature_changes")
        end
      end
    end
  end

  describe 'Previous button' do
    before(:each) do
      @input_species = create_cites_eu_species
      @lump = create(:nomenclature_change_lump)
      create(:nomenclature_change_input, nomenclature_change: @lump, taxon_concept: @input_species)
      create(:nomenclature_change_output, nomenclature_change: @lump)
    end
    context 'when step is legislation' do
      it 'renders notes step' do
        get :show, id: :notes, nomenclature_change_id: @lump.id, back: true
        response.should render_template('notes')
      end
    end
    context 'when step is summary' do
      context 'when legislation' do
        before(:each) do
          create_cites_I_addition(taxon_concept: @input_species)
        end
        it 'renders legislation step' do
          get :show, id: :legislation, nomenclature_change_id: @lump.id, back: true
          response.should render_template('legislation')
        end
      end
      context 'when no legislation' do
        it 'redirects to notes step' do
          get :show, id: :legislation, nomenclature_change_id: @lump.id, back: true
          response.should redirect_to action: :show, id: :notes
          get :show, id: :notes, nomenclature_change_id: @lump.id
          response.should redirect_to action: :show, id: :notes
        end
      end
    end
  end

end
