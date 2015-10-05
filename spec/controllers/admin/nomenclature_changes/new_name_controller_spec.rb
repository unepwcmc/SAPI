require 'spec_helper'

describe Admin::NomenclatureChanges::NewNameController do
  login_admin

  describe 'GET show' do
    before(:each) do
      @new_name = create(:nomenclature_change_new_name)
    end
    context :name_status do
      it 'renders the name_status template' do
        get :show, id: :name_status, nomenclature_change_id: @new_name.id
        response.should render_template('name_status')
      end
    end
    context :taxonomy do
      it 'renders the taxonomy template' do
        get :show, id: :taxonomy, nomenclature_change_id: @new_name.id
        response.should render_template('taxonomy')
      end
    end
    context :rank do
      it 'renders the taxonomy template' do
        get :show, id: :rank, nomenclature_change_id: @new_name.id
        response.should render_template('rank')
      end
    end
    context 'when is an accepted name' do
      before(:each) do
        @taxonomy = create(:taxonomy, name: "CITES_EU")
        create(:nomenclature_change_output,
          nomenclature_change: @new_name,
          new_name_status: 'A',
          taxonomy_id: @taxonomy.id
        )
      end
      it 'renders the parent template' do
        get :show, id: :parent, nomenclature_change_id: @new_name.id
        response.should render_template('parent')
      end
    end
    context 'when is a synonym' do
      before(:each) do
        @taxonomy = create(:taxonomy, name: "CITES_EU")
        create(:nomenclature_change_output,
          nomenclature_change: @new_name,
          new_name_status: 'S',
          taxonomy_id: @taxonomy.id 
        )
      end
      it 'renders the accepted_names template' do
        get :show, id: :accepted_names, nomenclature_change_id: @new_name.id
        response.should render_template('accepted_names')
      end
    end
    context 'when is an hybrid' do
      before(:each) do
        @taxonomy = create(:taxonomy, name: "CITES_EU")
        create(:nomenclature_change_output,
          nomenclature_change: @new_name,
          new_name_status: 'H',
          taxonomy_id: @taxonomy.id 
        )
      end
      it 'renders the hybrid_parents template' do
        get :show, id: :hybrid_parents, nomenclature_change_id: @new_name.id
        response.should render_template('hybrid_parents')
      end
    end
    context :scientific_name do
      it 'renders the scientific name template' do
        get :show, id: :scientific_name, nomenclature_change_id: @new_name.id
        response.should render_template('scientific_name')
      end
    end
    context :summary do
      before(:each) do
        @taxonomy = create(:taxonomy, name: "CITES_EU")
        create(:nomenclature_change_output,
          nomenclature_change: @new_name,
          new_name_status: 'S',
          taxonomy_id: @taxonomy.id
        )
      end
      it 'renders the summary template' do
        get :show, id: :summary, nomenclature_change_id: @new_name.id
        response.should render_template('summary')
      end
    end
  end
  
  describe 'POST create' do
    it 'redirects to new_name wizard' do
      post :create, nomenclature_change_id: 'new'
      response.should redirect_to(admin_nomenclature_change_new_name_url(
        nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'name_status'
      ))
    end
  end

  describe 'PUT update' do
    before(:each) do
      @new_name = create(:nomenclature_change_new_name)
      @taxonomy = create(:taxonomy, name: "CITES_EU")
      @rank = create(:rank, name: "SUBSPECIES")
    end
    context 'when successful' do
      it 'redirects to next step' do
        put :update, nomenclature_change_new_name: {
          output_attributes: { new_name_status: 'A' },
        }, nomenclature_change_id: @new_name.id, id: 'name_status'
        response.should redirect_to(admin_nomenclature_change_new_name_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'taxonomy'
        ))
      end
    end
    context 'when unsuccessful' do
      it 're-renders step' do
        put :update, nomenclature_change_new_name: {
          output_attributes: { new_scientific_name: nil }
        }, nomenclature_change_id: @new_name.id, id: 'scientific_name'
        response.should render_template('scientific_name')
      end
    end
    context 'when is accepted name' do
      it 'redirects to parent step' do
        put :update, nomenclature_change_new_name: {
          output_attributes: { 
            new_name_status: 'A',
            taxonomy_id: @taxonomy.id,
            rank_id: @rank.id
          },
        }, nomenclature_change_id: @new_name.id, id: 'rank'
        response.should redirect_to(admin_nomenclature_change_new_name_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'parent'
        ))
      end
    end
    context 'when is synonym' do
      it 'redirects to accepted names step' do
        put :update, nomenclature_change_new_name: {
          output_attributes: { 
            new_name_status: 'S',
            taxonomy_id: @taxonomy.id,
            rank_id: @rank.id
          },
        }, nomenclature_change_id: @new_name.id, id: 'rank'
        response.should redirect_to(admin_nomenclature_change_new_name_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'accepted_names'
        ))
      end
    end
    context 'when is synonym' do
      it 'redirects to hybrid parents step' do
        put :update, nomenclature_change_new_name: {
          output_attributes: { 
            new_name_status: 'H',
            taxonomy_id: @taxonomy.id,
            rank_id: @rank.id
          },
        }, nomenclature_change_id: @new_name.id, id: 'rank'
        response.should redirect_to(admin_nomenclature_change_new_name_url(
          nomenclature_change_id: assigns(:nomenclature_change).id, :id => 'hybrid_parents'
        ))
      end
    end
  end
end
