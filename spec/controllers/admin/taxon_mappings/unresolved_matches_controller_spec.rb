require 'spec_helper'

describe Admin::TaxonMappings::UnresolvedMatchesController do
  let!(:cites) { MatchableTaxonomy.create!(code: 'CITES', name: 'CITES') }
  let!(:iucn) { MatchableTaxonomy.create!(code: 'IUCN', name: 'IUCN Red List') }

  def match(near_nid: '1', far_nid: '9', file: 'matches.csv')
    MappingMatch.create!(
      matchable_taxonomy: cites, taxon_nid: near_nid,
      foreign_matchable_taxonomy: iucn, foreign_taxon_nid: far_nid,
      matched_name: 'Panthera leo', matched_name_status: 'A',
      foreign_matched_name: 'Panthera leo', foreign_matched_name_status: 'A',
      match_confidence: 'high', source_file: file
    )
  end

  def taxon(taxonomy, nid)
    MappingTaxon.create!(
      matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: nid,
      name_status: 'A', scientific_name: 'Panthera leo', source_file: 'taxa.csv'
    )
  end

  def get_index(side: 'near', taxonomy: cites, file: 'matches.csv')
    get :index, params: {
      matchable_taxonomy_id: taxonomy.id, side: side, source_file: file
    }
  end

  describe 'as a manager' do
    login_admin

    it 'lists the matches naming a taxon we do not hold' do
      unresolved = match(near_nid: '1')
      taxon(iucn, '9')

      get_index
      expect(assigns(:matches)).to eq [ unresolved ]
    end

    it 'leaves out the ones that do resolve' do
      match(near_nid: '1')
      taxon(cites, '1')
      taxon(iucn, '9')

      get_index
      expect(assigns(:matches)).to be_empty
    end

    it 'reads the far side when asked for it' do
      # The same match is unresolved on the IUCN side too, under its own count.
      unresolved = match
      taxon(cites, '1')

      get_index(side: 'foreign', taxonomy: iucn)
      expect(assigns(:matches)).to eq [ unresolved ]
    end

    it 'keeps to the export the count came from' do
      match(near_nid: '1', file: 'other.csv')

      get_index(file: 'matches.csv')
      expect(assigns(:matches)).to be_empty
    end

    it 'falls back to the near side rather than failing on a bad side' do
      match(near_nid: '1')

      get_index(side: 'nonsense')
      expect(assigns(:side)).to eq :near
    end
  end

  describe 'as a contributor' do
    login_contributor

    it 'is refused' do
      get_index
      expect(response).to be_redirect
    end
  end
end
