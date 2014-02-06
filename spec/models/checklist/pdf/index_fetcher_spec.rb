require 'spec_helper'

describe Checklist::Pdf::IndexFetcher do
  let(:en){ 
    create(:language, :name => 'French', :iso_code1 => 'FR', :iso_code3 => 'FRA')
    create(:language, :name => 'Spanish', :iso_code1 => 'ES', :iso_code3 => 'SPA')
    create(:language, :name => 'English', :iso_code1 => 'EN', :iso_code3 => 'ENG')
  }
  let(:es){ 
    Language.find_by_name_en("Spanish")
  }

  let(:english_common_name){
    create(
      :common_name,
      :name => 'Domestic lolcat',
      :language => en
    )
  }
  let(:spanish_common_name){ 
    create(
      :common_name,
      :name => 'Lolgato domestico',
      :language => es
    )
  }
  let!(:tc){
    tc = create(
      :taxon_concept,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
    )
    tc.common_names << english_common_name
    tc.common_names << spanish_common_name
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    tc
  }
  let(:rel){ MTaxonConcept.by_scientific_name('Lolcatus') }

  context "with common names" do
    let(:query){
      Checklist::Pdf::IndexQuery.new(
        rel, {
          :english_common_names => true,
          :spanish_common_names => true
        }
      )
    }
    subject{ Checklist::Pdf::IndexFetcher.new(query) }
    specify{ subject.next.first.sort_name.should == 'lolcat, Domestic' }
  end
  context "with synonyms and authors" do
    let(:synonym_relationship_type){
      create(
        :taxon_relationship_type,
        :name => TaxonRelationshipType::HAS_SYNONYM,
        :is_intertaxonomic => false,
        :is_bidirectional => false
      )
    }
    let!(:synonym){
      create(
        :taxon_concept,
        :name_status => 'S',
        :full_name => 'Catus fluffianus'
      )
    }
    let!(:synonymy_rel){
      create(
        :taxon_relationship,
        :taxon_relationship_type => synonym_relationship_type,
        :taxon_concept_id => tc.id,
        :other_taxon_concept_id => synonym.id,
      )
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    }
    let(:query){
      Checklist::Pdf::IndexQuery.new(
        rel, {
          :synonyms => true,
          :authors => true
        }
      )
    }
    subject{ Checklist::Pdf::IndexFetcher.new(query) }
    specify{ subject.next.first.sort_name.should == 'Catus fluffianus' }
  end
end
