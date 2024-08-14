require 'spec_helper'

describe Checklist::Pdf::History do
  let(:en) { create(:language, name: 'English', iso_code1: 'EN') }
  let!(:fr) { create(:language, name: 'French', iso_code1: 'FR') }
  let!(:es) { create(:language, name: 'Spanish', iso_code1: 'ES') }
  let(:family_tc) do
    tc = create_cites_eu_family(
      taxon_name: create(:taxon_name, scientific_name: 'Foobaridae')
    )
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  end
  let(:genus_tc) do
    tc = create_cites_eu_genus(
      parent_id: family_tc.id,
      taxon_name: create(:taxon_name, scientific_name: 'Foobarus')
    )
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  end
  describe :higher_taxon_name do
    context 'when family' do
      let(:tc) { family_tc }
      let!(:taxon_common) do
        create(
          :taxon_common,
          taxon_concept_id: tc.id,
          common_name: create(
            :common_name,
            name: 'Foobars',
            language: en
          )
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      end
      subject { Checklist::Pdf::History.new(scientific_name: tc.full_name, show_english: true) }
      specify do
        expect(subject.higher_taxon_name(tc.reload)).to eq("\\subsection*{FOOBARIDAE  (E) Foobars }\n")
      end
    end
  end

  describe :listed_taxon_name do
    context 'when family' do
      let(:tc) { family_tc }
      let!(:lc) do
        lc = create_cites_I_addition(
          taxon_concept_id: tc.id,
          is_current: true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MCitesListingChange.find(lc.id)
      end
      subject { Checklist::Pdf::History.new(scientific_name: tc.full_name) }
      specify do
        expect(subject.listed_taxon_name(tc)).to eq('FOOBARIDAE spp.')
      end
    end
    context 'when genus' do
      let(:tc) { genus_tc }
      let!(:lc) do
        lc = create_cites_I_addition(
          taxon_concept_id: tc.id,
          is_current: true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MCitesListingChange.find(lc.id)
      end
      subject { Checklist::Pdf::History.new(scientific_name: tc.full_name) }
      specify do
        expect(subject.listed_taxon_name(tc)).to eq('\emph{Foobarus} spp.')
      end
    end
  end

  describe :annotation_for_language do
    context 'annotation with footnote' do
      let(:annotation) do
        create(
          :annotation,
          short_note_en: 'Except <i>Foobarus cracoviensis</i>',
          full_note_en: '...',
          display_in_footnote: true
        )
      end
      let(:tc) { genus_tc }
      let(:lc) do
        lc = create_cites_I_addition(
          taxon_concept_id: tc.id,
          annotation_id: annotation.id,
          is_current: true,
          nomenclature_note_en: 'Previously listed as <i>Foobarus polonicus</i>.'
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MCitesListingChange.find(lc.id)
      end
      subject { Checklist::Pdf::History.new({}) }
      specify do
        expect(subject.annotation_for_language(lc, 'en')).to eq("Except \\textit{Foobarus cracoviensis}\n\nPreviously listed as \\textit{Foobarus polonicus}.\\footnote{...}")
      end
    end
  end
end
