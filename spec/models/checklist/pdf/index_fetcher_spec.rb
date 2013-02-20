require 'spec_helper'

describe Checklist::Pdf::IndexFetcher do
  let(:english){ Language.find_by_iso_code1('en') || create(:language, :iso_code1 => 'en') }
  let(:spanish){ Language.find_by_iso_code1('es') || create(:language, :iso_code1 => 'es') }
  let(:english_common_name){
    create(
      :common_name,
      :name => 'Domestic lolcat',
      :language => english
    )
  }
  let(:spanish_common_name){ 
    create(
      :common_name,
      :name => 'Lolgato domestico',
      :language => spanish
    )
  }
  let!(:tc){
    tc = create(
      :taxon_concept,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
    )
    tc.common_names << english_common_name
    tc.common_names << spanish_common_name
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
    let!(:synonym){
      create(
        :taxon_concept,
        :name_status => 'S',
        :full_name => 'Catus fluffianus'
      )
    }
    let!(:synonymy_rel){
      create(
        :has_synonym,
        :taxon_concept_id => tc.id,
        :other_taxon_concept_id => synonym.id,
      )
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