require 'spec_helper'

describe Checklist::Pdf::IndexFetcher do
  let(:en) do
    create(:language, name_en: 'French', iso_code1: 'FR', iso_code3: 'FRA')
    create(:language, name_en: 'Spanish', iso_code1: 'ES', iso_code3: 'SPA')
    create(:language, name_en: 'English', iso_code1: 'EN', iso_code3: 'ENG')
  end
  let(:es) do
    Language.find_by_name_en('Spanish')
  end

  let(:english_common_name) do
    create(
      :common_name,
      name: 'Domestic lolcat',
      language: en
    )
  end
  let(:spanish_common_name) do
    create(
      :common_name,
      name: 'Lolgato domestico',
      language: es
    )
  end
  let!(:tc) do
    tc = create(
      :taxon_concept,
      taxon_name: create(:taxon_name, scientific_name: 'Lolcatus')
    )
    tc.common_names << english_common_name
    tc.common_names << spanish_common_name
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
    tc
  end
  let(:rel) { MTaxonConcept.by_scientific_name('Lolcatus') }

  context 'with common names' do
    let(:query) do
      Checklist::Pdf::IndexQuery.new(
        rel, {
          english_common_names: true,
          spanish_common_names: true
        }
      )
    end
    subject { Checklist::Pdf::IndexFetcher.new(query) }
    specify { expect(subject.next.first.sort_name).to eq('lolcat, Domestic') }
  end
  context 'with synonyms and authors' do
    let!(:synonym) do
      create(
        :taxon_concept,
        name_status: 'S',
        scientific_name: 'Catus fluffianus'
      )
    end
    let!(:synonymy_rel) do
      create(
        :taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: synonym.id
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
    end
    let(:query) do
      Checklist::Pdf::IndexQuery.new(
        rel, {
          synonyms: true,
          authors: true
        }
      )
    end
    subject { Checklist::Pdf::IndexFetcher.new(query) }
    specify { expect(subject.next.first.sort_name).to eq('Catus fluffianus') }
  end
end
