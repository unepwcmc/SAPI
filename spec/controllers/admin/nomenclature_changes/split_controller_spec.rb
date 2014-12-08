require 'spec_helper'

describe Admin::NomenclatureChanges::SplitController do
  login_admin
  include_context 'split_definitions'

  describe 'GET show' do
    context :inputs do
      before(:each) do
        @split = create(:nomenclature_change_split)
      end
      it 'renders the inputs template' do
        get :show, id: :inputs, nomenclature_change_id: @split.id
        response.should render_template('inputs')
      end
    end
    context :outputs do
      before(:each) do
        @split = split_with_input
      end
      it 'renders the outputs template' do
        get :show, id: :outputs, nomenclature_change_id: @split.id
        response.should render_template('outputs')
      end
    end
    context :reassignments do
      before(:each) do
        @split = split_with_input_and_output
      end
      it 'renders the notes template' do
        get :show, id: :notes, nomenclature_change_id: @split.id
        response.should render_template('notes')
      end
      context "when children present" do
        before(:each) do
          create_cites_eu_subspecies(parent: input_species)
        end
        it 'renders the children template' do
          get :show, id: :children, nomenclature_change_id: @split.id
          response.should render_template('children')
        end
      end
      context "when no children" do
        it 'redirects to next step' do
          get :show, id: :children, nomenclature_change_id: @split.id
          response.should redirect_to(admin_nomenclature_change_split_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'names'
          ))
        end
      end
      context "when names present" do
        before(:each) do
          create(:taxon_relationship,
            taxon_concept: input_species,
            other_taxon_concept: create_cites_eu_species(name_status: 'S'),
            taxon_relationship_type: synonym_relationship_type
          )
        end
        it 'renders the names template' do
          get :show, id: :names, nomenclature_change_id: @split.id
          response.should render_template('names')
        end
      end
      context "when no names" do
        it 'redirects to next step' do
          get :show, id: :names, nomenclature_change_id: @split.id
          response.should redirect_to(admin_nomenclature_change_split_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'distribution'
          ))
        end
      end
      context "when distribution present" do
        before(:each) do
          create(:distribution, taxon_concept: input_species)
        end
        it 'renders the distribution template' do
          get :show, id: :distribution, nomenclature_change_id: @split.id
          response.should render_template('distribution')
        end
      end
      context "when no distribution" do
        it 'redirects to next step' do
          get :show, id: :distribution, nomenclature_change_id: @split.id
          response.should redirect_to(admin_nomenclature_change_split_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'legislation'
          ))
        end
      end
      context "when legislation present" do
        before(:each) do
          create_cites_I_addition(taxon_concept: input_species)
        end
        it 'renders the legislation template' do
          get :show, id: :legislation, nomenclature_change_id: @split.id
          response.should render_template('legislation')
        end
      end
      context "when no legislation" do
        it 'redirects to next step' do
          get :show, id: :legislation, nomenclature_change_id: @split.id
          response.should redirect_to(admin_nomenclature_change_split_url(
            nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'summary'
          ))
        end
      end
      it 'renders the summary template' do
        get :show, id: :summary, nomenclature_change_id: @split.id
        response.should render_template('summary')
      end
    end
  end

  describe 'POST create' do
    it 'redirects to split wizard' do
      post :create, nomenclature_change_id: 'new'
      response.should redirect_to(admin_nomenclature_change_split_url(
        nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'inputs'
      ))
    end
  end

  describe 'PUT update' do
    before(:each) do
      @split = create(:nomenclature_change_split)
    end
    context 'when successful' do
      it 'redirects to next step' do
        put :update, nomenclature_change_split: {
          input_attributes: {taxon_concept_id: create_cites_eu_species.id}
        }, nomenclature_change_id: @split.id, id: 'inputs'
        response.should redirect_to(admin_nomenclature_change_split_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'outputs'
        ))
      end
    end
    context 'when unsuccessful' do
      it 're-renders step' do
        put :update, nomenclature_change_split: {
            input_attributes: {taxon_concept_id: nil}
          }, nomenclature_change_id: @split.id, id: 'inputs'
        response.should render_template('inputs')
      end
    end
  end

end
